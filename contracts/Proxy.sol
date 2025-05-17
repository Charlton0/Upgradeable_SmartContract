// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Simplified EIP-1967 Proxy Contract
/// @notice Allows upgrading implementation address following EIP-1967 standard
/// @dev Uses delegatecall to forward calls to implementation contract
contract ProxyEIP1967 {
    // Storage slot with the address of the current implementation.
    // bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // Storage slot with the admin of the proxy.
    // bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e01a5b8b34c5b64c1d9f6a5b1e0bde6f3;

    event Upgraded(address indexed implementation);
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == _admin(), "Proxy: caller is not admin");
        _;
    }

    constructor(address _implementation) {
        _setAdmin(msg.sender);
        _setImplementation(_implementation);
    }

    /// @notice Fallback function that delegates calls to the implementation
    fallback() external payable {
        _delegate(_implementation());
    }

    receive() external payable {
        _delegate(_implementation());
    }

    /// @notice Upgrade implementation contract address
    /// @param newImplementation Address of the new implementation contract
    function upgradeTo(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "Proxy: new implementation is zero address");
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /// @notice Change proxy admin address
    /// @param newAdmin Address of the new admin
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Proxy: new admin is zero address");
        emit AdminChanged(_admin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /// @notice Returns current implementation address
    function implementation() external view returns (address) {
        return _implementation();
    }

    /// @notice Returns current admin address
    function admin() external view returns (address) {
        return _admin();
    }

    // Internal function to delegate calls to implementation
    function _delegate(address impl) internal {
        assembly {
            // Copy calldata to memory starting at position 0
            calldatacopy(0, 0, calldatasize())
            // delegatecall(gas, address, in_mem_pos, in_mem_size, out_mem_pos, out_mem_size)
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            // Copy returned data to memory
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // Internal function to get implementation address from EIP-1967 slot
    function _implementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    // Internal function to set implementation address in EIP-1967 slot
    function _setImplementation(address newImplementation) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }

    // Internal function to get admin address from EIP-1967 slot
    function _admin() internal view returns (address adm) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            adm := sload(slot)
        }
    }

    // Internal function to set admin address in EIP-1967 slot
    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, newAdmin)
        }
    }
}
