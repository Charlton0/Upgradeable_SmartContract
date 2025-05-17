# Upgradeable Smart Contract Using EIP-1967 Proxy Standard

## Overview

Smart contracts on Ethereum are immutable by default, meaning once deployed, their code cannot be changed. This presents challenges when you want to fix bugs, add features, or upgrade your contract logic. Proxy contracts solve this by separating the contract’s **storage** and **logic** into two contracts:

- **Proxy Contract:** Holds the contract state (storage) and delegates calls to the implementation contract.
- **Implementation Contract:** Contains the logic and can be swapped/upgraded by changing the address in the proxy.

## Why Upgradeability?

Upgradeability allows developers to:

- Patch bugs without losing state.
- Add new features.
- Adapt to changing requirements.
- Maintain continuous service without redeploying new contracts to users.

## Proxy Patterns

There are several proxy patterns, including:

- **Transparent Proxy Pattern:** Uses an admin to upgrade implementations and avoid collision with user calls.
- **Universal Upgradeable Proxy Standard (UUPS):** Logic contract has the upgrade function and requires the proxy to delegate calls properly.
- **EIP-1967 Standard:** Defines standardized storage slots for the proxy to store the implementation address and admin, preventing storage collisions.

## EIP-1967 Details

EIP-1967 proposes fixed storage slots for proxy data to avoid conflicts between proxy and implementation contract storage:

- Implementation address stored at `bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)`
- Admin address stored at `bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)`

This prevents overwriting important storage variables in the implementation contract.

## How It Works

- The proxy receives calls and delegates them to the implementation using `delegatecall`.
- The implementation logic executes in the proxy’s context, so storage is preserved.
- Admin can upgrade the implementation by updating the address in the fixed slot.

## Security Considerations

- Only the admin should be allowed to upgrade the implementation.
- The proxy must prevent admin functions from being called through fallback to avoid conflicts.
- Careful management of storage layout between implementations is required.

## References

- [EIP-1967: Proxy Storage Slots](https://eips.ethereum.org/EIPS/eip-1967)
- [OpenZeppelin Upgrades Documentation](https://docs.openzeppelin.com/upgrades/2.3/)
- [Solidity Documentation](https://docs.soliditylang.org/en/v0.8.19/)

---

