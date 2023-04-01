//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Exchange {
    address public owner;
    mapping(address => mapping(address => uint)) public balances;
    mapping(address => bool) public authorizedTokens;
    uint public fee = 0.1 ether;

    event Deposit(address indexed token, address indexed user, uint amount);
    event Withdraw(address indexed token, address indexed user, uint amount);
    event Trade(address indexed token, address indexed buyer, address indexed seller, uint price);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deposit(address token, uint amount) public {
        require(authorizedTokens[token], "Token is not authorized");
        require(amount > 0, "Amount must be grater than zero");

        balances[token][msg.sender] += amount;
        emit Deposit(token, msg.sender, amount);
    }

    function withdraw(address token, uint amount) public {
        require(balances[token][msg.sender] >= amount, "Insufficient balances");

        balances[token][msg.sender] -= amount;
        emit Withdraw(token, msg.sender, amount);
    }

    function authorizedToken(address token) public onlyOwner {
        authorizedTokens[token] = true;
    }

    function revokeToken(address token) public onlyOwner {
        authorizedTokens[token] = false;
    }

    function setFee(uint newFee) public onlyOwner {
        fee = newFee;
    }

    function trade(address token, address seller, uint amount, uint price) public payable {
        require(msg.value == fee, "Insufficient fee");
        require(balances[token][seller] >= amount, "Insufficient balances");
        require(balances[address(this)][msg.sender] >= amount * price, "Insufficient exchange balance");

        balances[token][seller] -= amount;
        balances[token][msg.sender] += amount;
        balances[address(this)][msg.sender] -= amount * price;
        balances[address(this)][seller] += amount * price;

        emit Trade(token, msg.sender, seller, price);



    }


}
