//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Accounting {
    struct Transaction {
        uint amount;
        address sender;
        address receiver;
        uint timestamp;
        string description;
    }

    mapping(address => uint) public balances;
    Transaction[] public transactions;
    address public owner;

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);
    event TransactionAdded(uint indexed id, uint amount, address indexed sender, address indexed receiver, uint timestamp, string description);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function deposit() public payable {
        require(msg.value > 0, "Amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public {
        require(amount > 0, "Amount must be grater tahn zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }

    function addTransaction(address receiver, uint amount, string memory description) public {
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        transactions.push(Transaction(amount, msg.sender, receiver, block.timestamp, description));
        emit TransactionAdded(transactions.length - 1, amount, msg.sender, receiver, block.timestamp, description);
    }

    function getTransactionCount() public view returns(uint) {
        return transactions.length;
    }

    function getTransactionById(uint id) public view returns(uint, address, address, uint, string memory) {
        require(id < transactions.length, "Invalid transaction Id");

        Transaction memory transaction = transactions[id];
        return(transaction.amount, transaction.sender, transaction.receiver, transaction.timestamp, transaction.description);
    }



}
