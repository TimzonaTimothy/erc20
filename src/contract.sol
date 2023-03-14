// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//used these address ["0x109D25547BD97E4ED7f8362f27e50F084521D033"] in deployment and set the required number of confirmation of mint and burn to 1

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.3/contracts/access/Ownable.sol";

// Define the contract GNaira which is an ERC20 token contract that also has multi-signature functionality
contract GNaira is ERC20 {
  
  // events that will be emitted by the contract
  event Deposit(address indexed sender, address indexed token, uint amount);
  event Submit(uint indexed txId);
  event Approve(address indexed owner, uint indexed txId);
  event Revoke(address indexed owner, uint indexed txId);
  event Execute(uint indexed txId);
  event blackListEvent(address indexed _sender, string _comment);
  event removeBlackListEvent(address indexed _sender, string _comment);
  event Mint(uint indexed txId);
  event Burn(uint indexed txId);

  //struct for a transaction, which includes the recipient address, amount, transaction data, and execution status
  struct Transaction {
    address to;
    uint amount;
    bytes data;
    bool executed;
  }

  address[] public owners;

  // mapping to check if an address is an owner of the contract
  mapping(address => bool) public isOwner;
  uint public required;
  
  //mapping to check if an address is blacklisted
  mapping(address=> bool) isBlacklisted;

  //array to store all submitted transactions
  Transaction[] public transactions;

  //mapping to track the approvals for each transaction
  mapping(uint => mapping(address => bool)) public approved;

  //modifier that checks if the caller is an owner of the contract
  modifier onlyGovernor() {
    require(isOwner[msg.sender] == true, "MultiSigWallet::onlyGovernor: only owner can call this method");
    _;
  }

  //modifier that checks if a transaction exists
  modifier txExists(uint _txId) {
    require(_txId < transactions.length, "MultiSigWallet::txExists: transaction does not exist");
    _;
  }

  //modifier that checks if the caller has not yet approved a transaction
  modifier notApproved(uint _txId) {
    require(approved[_txId][msg.sender] != true, "MultiSigWallet::notApproved: transaction is already approved by this owner");
    _;
  }

  //modifier that checks if a transaction has not yet been executed
  modifier notExecuted(uint _txId) {
    require(transactions[_txId].executed != true, "MultiSigWallet::notExecuted: transaction is already executed");
    _;
  }

  //constructor function for the contract, which initializes the owners and the required number of the owners
  constructor(address[] memory _owners, uint _required) ERC20("G-Naira", "gNGN") {
    
    require(_owners.length > 0, "MultiSigWallet::constructor: there must be at least one owner");
    require(_required > 0 && _required <= _owners.length, "MultiSigWallet::constructor: invalid required number of owners");

    for (uint i; i < _owners.length; i++) {
      address owner = _owners[i];
      
      require(owner != address(0), "MultiSigWallet::constructor: zero address cannot be the owner");
      require(!isOwner[owner], "MultiSigWallet::constructor: can't have duplicate owners");

      isOwner[owner] = true;
      owners.push(owner);
    }

    required = _required;
  }

  //function to blacklist an address
  function blackList(address _user) public onlyGovernor
    {
        require(!isBlacklisted[_user],"user is already blacklisted");
        isBlacklisted[_user] = true;
        emit blackListEvent(_user, "added to blacklist");
    }

    function removeFromBlacklist(address _user) public onlyGovernor{
      require(isBlacklisted[_user],"use is already whitelisted");
      isBlacklisted[_user] = false;
      emit removeBlackListEvent(_user, "removed from blacklist");
    }

  //function that modifies the transferFrom which checks wether an address is blacklist before execution 
  function transfer( address _to, uint256 _amount) override public returns (bool) {
    require(isBlacklisted[msg.sender], "Sender is blacklisted");
    require(isBlacklisted[_to], "Recipiant is blacklisted");
    
    ERC20(address(this)).transferFrom(msg.sender, _to, _amount);
    return true;
    emit Deposit(msg.sender, _to, _amount);
  }

  //mint function
  function mint(uint _amount) external onlyGovernor {
    transactions.push(Transaction({
      to: msg.sender,
      amount: _amount,
      data: "mint",
      executed: false
    }));

    emit Submit(transactions.length - 1);
    
  }

  function transactionCount() public view returns(uint){
    return transactions.length;
  }


//this function helps to tracks all the mint and burn transactions made by a particular address
function getTransactionsByAddress(address _address) public view returns (Transaction[] memory) {
    uint count = 0;
    for (uint i = 0; i < transactions.length; i++) {
        if (transactions[i].to == _address) {
            count++;
        }
    }
    Transaction[] memory result = new Transaction[](count);
    count = 0;
    for (uint i = 0; i < transactions.length; i++) {
        if (transactions[i].to == _address) {
            result[count] = transactions[i];
            count++;
        }
    }
    return result;
}

  //burn function
  function burn(uint _amount) external onlyGovernor {
    transactions.push(Transaction({
      to: msg.sender,
      amount: _amount,
      data: "burn",
      executed: false
    }));
    
    emit Submit(transactions.length - 1);
    
  }

  //function to approve a transaction
  function approvetxn(uint _txId) external onlyGovernor txExists(_txId) notApproved(_txId) notExecuted(_txId) {
    approved[_txId][msg.sender] = true;
    emit Approve(msg.sender, _txId);
  }
  
  //function to revoke a transaction
  function revoke(uint _txId) external onlyGovernor txExists(_txId) notExecuted(_txId) {
    require(approved[_txId][msg.sender] == true, "MultiSigWallet::revoke: transaction is not approved");
    approved[_txId][msg.sender] = false;
    emit Revoke(msg.sender, _txId);
  }

  //function that counts the number of approvals done by the governors
  function _getApprovalCount(uint _txId) public view returns(uint count) {
    for (uint i; i < owners.length; i++) {
      if (approved[_txId][owners[i]]) {
        count += 1;
      }
    }
  }


  //function that executes a transaction
  function execute(uint _txId) external onlyGovernor txExists(_txId) notExecuted(_txId) {
    require(_getApprovalCount(_txId) >= required, "MultiSigWallet::execute: approvals are less than required");
    Transaction storage transaction = transactions[_txId];
    
    transaction.executed = true;
    if (keccak256(transaction.data) == keccak256("mint")) {
        _mint(transaction.to, transaction.amount);
        emit Mint(_txId);
    } else if (keccak256(transaction.data) == keccak256("burn")) {
        _burn(transaction.to, transaction.amount);
        emit Burn(_txId);
    } else {
        revert("MultiSigWallet::execute: invalid transaction data");
    }
  }

} 