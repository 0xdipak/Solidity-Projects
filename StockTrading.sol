//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract StockTrading {
    struct Stock {
        uint price;
        uint quantity;
    }

    mapping(string => Stock) public stocks;
    mapping(address => mapping(string => uint)) public balances;

    address public hedgeFund;

    event StockBought(address buyer, string stockName, uint price, uint quantity);
    event StockSold(address seller, string stockName, uint price, uint quantity);

    constructor() {
        hedgeFund = msg.sender;
    }

    modifier onlyHedgeFund() {
        require(msg.sender == hedgeFund, "Only hedgeFund can call this function");
        _;
    }

    function buyStock(string memory stockName, uint quantity) public payable {
        Stock memory stock = stocks[stockName];
        require(stock.price > 0, "Stock does not exist");
        require(msg.value >= stock.price * quantity, "Insufficient funds");
        balances[msg.sender][stockName] += quantity;
        stocks[stockName].quantity -= quantity;
        emit StockBought(msg.sender, stockName, stock.price, quantity);
    }

    function sellStock(string memory stockName, uint quantity) public {
        Stock memory stock = stocks[stockName];
        require(stock.quantity >= quantity, "Insufficient stock");
        require(balances[msg.sender][stockName] >= quantity, "Insufficient stock balance");

        balances[msg.sender][stockName] -= quantity;
        stocks[stockName].quantity += quantity;
        payable(msg.sender).transfer(stock.price * quantity);
        emit StockSold(msg.sender, stockName, stock.price, quantity);
    }

    function addStock(string memory stockName, uint price, uint quantity) public onlyHedgeFund {
        Stock memory stock = stocks[stockName];
        require(stock.price == 0, "Stock already exits");

        stocks[stockName] = Stock(price, quantity);
    }

    function updateStockPrice(string memory stockName, uint price) public onlyHedgeFund {
        Stock memory stock = stocks[stockName];
        require(stock.price > 0, "Stock does not exist");

        stocks[stockName].price = price;
    }

    function withdrawFunds() public onlyHedgeFund {
        payable(hedgeFund).transfer(address(this).balance);
    }


}
