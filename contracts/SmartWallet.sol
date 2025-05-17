// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title SmartWallet with EIP-4337-like structure
 * This contract simulates the core ideas of Account Abstraction:
 * - Custom validation logic
 * - execute() function to perform arbitrary calls
 * - Nonce for replay protection
 * - Integration with a Paymaster contract
 * - Bonus: Batch calls and ERC20 gas payment
 */

// ERC20 token interface
interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
}

contract SmartWallet {
    address public owner;           // Address controlling the wallet
    uint256 public nonce;           // Used for replay protection
    address public paymaster;       // Authorized Paymaster contract
    IERC20 public gasToken;         // ERC20 token used for gas sponsorship

    // Events
    event Executed(address indexed target, uint256 value, bytes data);
    event BatchExecuted(uint count);
    event GasPaidWithToken(address token, address from, uint256 amount);

    constructor(address _owner, address _paymaster, address _gasToken) {
        owner = _owner;
        paymaster = _paymaster;
        gasToken = IERC20(_gasToken);
    }

    /// @notice Execute a single transaction from the wallet
    function execute(address to, uint value, bytes calldata data) external {
        require(msg.sender == owner, "Only owner can execute");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Call failed");

        nonce++;
        emit Executed(to, value, data);
    }

    /// @notice Batch multiple calls in a single transaction (Bonus feature)
    function executeBatch(address[] calldata to, uint[] calldata value, bytes[] calldata data) external {
        require(msg.sender == owner, "Only owner can execute");
        require(to.length == value.length && to.length == data.length, "Array lengths mismatch");

        for (uint i = 0; i < to.length; i++) {
            (bool success, ) = to[i].call{value: value[i]}(data[i]);
            require(success, "Batch call failed");
            nonce++;
        }

        emit BatchExecuted(to.length);
    }

    /// @notice Simulate validating a user operation (simplified EIP-4337 style)
    function validateUserOp(bytes32 hash, bytes calldata /* signature */) external view returns (bool) {
        // Simulated validation: compare expected hash with input hash
        bytes32 expected = keccak256(abi.encodePacked(owner, nonce));
        return hash == expected;
    }

    /// @notice Pay for gas using ERC20 token via Paymaster (Bonus feature)
    function payForGas(uint amount) external {
        require(msg.sender == paymaster, "Only paymaster allowed");
        require(gasToken.transferFrom(owner, paymaster, amount), "Token transfer failed");
        emit GasPaidWithToken(address(gasToken), owner, amount);
    }

    /// @notice Accepts ETH into the wallet
    receive() external payable {}
}


/**
 *@title Paymaster Contract
 *This contract sponsors gas for SmartWallet users by sending ETH or receiving ERC20s
 */
contract Paymaster {
    address public admin;
    event GasSponsored(address indexed user, uint256 amount);

    constructor() {
        admin = msg.sender;
    }

 /**
 * @notice Sponsor gas by sending ETH to the user's SmartWallet
 * @param walletAddress The address of the SmartWallet to receive ETH
 */
  function sponsorGas(address walletAddress) external payable {
        require(msg.value > 0, "No ETH sent");

        address payable userPayable = payable(walletAddress);
        (bool success, ) = userPayable.call{value: msg.value}("");
        require(success, "ETH transfer failed");

        emit GasSponsored(walletAddress, msg.value);
    }



    /// @notice Accepts ETH sent directly to the contract
    receive() external payable {}
}
