### GNaira Token Contract - Readme

This repository contains the Solidity smart contract for the GNaira (gNGN) token. GNaira is an ERC20 token contract that also implements multi-signature functionality for secure and controlled operations.

## Contract Information

License: MIT License
Solidity Version: ^0.8.0
Token Standard: ERC20
Deployment
The contract has been deployed with the following address:

Token Contract Address: [0xCONTRACT_ADDRESS]
During deployment, the contract was configured with the required number of confirmations for mint and burn transactions set to 1.

## Dependencies

This contract depends on the following external libraries:

OpenZeppelin ERC20 - An implementation of the ERC20 token standard.
OpenZeppelin Ownable - Provides basic authorization control functions.
These libraries are included using URLs directly in the contract code.

## Functionality

Multi-Signature Functionality
The GNaira contract implements multi-signature functionality, allowing multiple owners to collectively approve and execute specific transactions. Here are the key features related to multi-signature functionality:

## Owners

The contract is initialized with a list of owners who have the authority to approve transactions.
An owner is identified by their Ethereum address.
Only the owners can call functions that have the onlyGovernor modifier.

## Transactions

Transactions are submitted to the contract for approval before execution.
Each transaction includes the recipient address, amount, transaction data (mint or burn), and execution status.
Transactions are stored in the transactions array.

## Approval Workflow

Owners can approve or revoke their approval for a transaction.
A transaction requires a specific number of approvals to be executed, as set during deployment.

## Execution

Transactions can only be executed by the contract when the required number of approvals is reached.
The contract distinguishes between mint and burn transactions and executes the corresponding operations accordingly.

## Blacklist Functionality

The contract includes functionality to blacklist specific addresses. When an address is blacklisted, it cannot send or receive GNaira tokens. Here are the key features related to the blacklist functionality:

The blackList function can be called by owners to blacklist an address, preventing it from interacting with the token.
The removeFromBlacklist function can be called by owners to remove an address from the blacklist.

## Token Transfer

The contract overrides the transfer function from the ERC20 token standard to include additional checks:

Before executing a token transfer, it checks if the sender and the recipient addresses are blacklisted. If either address is blacklisted, the transfer is rejected.

## Events

The contract emits the following events to provide transparency and enable monitoring:

Deposit: Emitted when a transfer is made to a recipient address.
Submit: Emitted when a transaction is submitted for approval.
Approve: Emitted when an owner approves a transaction.
Revoke: Emitted when an owner revokes their approval for a transaction.
Execute: Emitted when a transaction is executed.
blackListEvent: Emitted when an address is added to the blacklist.
removeBlackListEvent: Emitted when an address is removed from the blacklist.
Mint: Emitted when a mint transaction is executed.
Burn: Emitted when a burn transaction is executed.

## Usage
This contract provides a robust ERC20 token with multi-signature functionality. It is designed to be controlled by a group of owners who collectively approve and execute specific transactions. Additionally, it includes a blacklist feature to prevent certain addresses from using the token.

## Note
  This readme file is for informational purposes only and does not constitute legal or financial advice. Use the contract at your own risk and discretion. Before deploying or interacting with the contract, ensure you understand its functionality and implications. Review the contract code and its dependencies carefully. If you plan to use this contract in a production environment, consider seeking a professional security audit.




