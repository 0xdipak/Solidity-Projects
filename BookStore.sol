//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract BookStore {
    uint public tax;
    address immutable taxAccount;
    uint bookId;
    BookStruct[] books;

    mapping(address => BookStruct[]) public booksOf;
    mapping(uint => address) public sellerOf;
    mapping(uint => bool) public bookExist;


    struct BookStruct {
        uint id;
        address seller;
        string name;
        string description;
        string author;
        uint cost;
        uint timestamp;
    }

    event Sale (uint id, address indexed buyer, address indexed seller, uint cost, uint timestamp);
    event Created(uint id, address indexed seller, uint timestamp);

    constructor(uint _tax) {
        tax = _tax;
        taxAccount = msg.sender;
    }


    function createBook(string memory name, string memory description, string memory author, uint cost) public returns(bool) {
        require(bytes(name).length > 0, "Name Con Not Be Empty...");
        require(bytes(description).length > 0, "Description Con Not Be Empty...");
        require(bytes(author).length > 0, "Author Con Not Be Empty...");
        require(cost > 0 ether, "Price Con Not Be Empty...");

        sellerOf[bookId] = msg.sender;
        bookExist[bookId] = true;

        books.push(
            BookStruct(bookId++, msg.sender, name, description, author, cost, block.timestamp)
        );
        emit Created(bookId++, msg.sender, block.timestamp);
        return true;

    }

    function purchaseBook(uint id) public payable returns(bool){
        require(bookExist[id], "Book does not exist...");
        require(msg.value >= books[id].cost, "Insufficient Amount...");

        address seller = sellerOf[id];
        uint fee = (msg.value / 100) * tax;
        uint amount = msg.value - fee;

        payTo(seller, amount);
        payTo(taxAccount, fee);

        booksOf[msg.sender].push(books[id]);
        emit Sale(id, msg.sender, seller, books[id].cost, block.timestamp);
        bookExist[id] = false;
        return(true);
    }

    function payTo(address to, uint amount) internal returns(bool) {
        (bool success,) = payable(to).call{value: amount}("");
        require(success, "Payment Failed...");
        return true;
    }

    // These two functions are alternative of payTo function 😊😊😊😊
    // function transferTo(address to, uint amount) internal returns(bool) {
    //     payable(to).transfer(amount);
    //     return true;
    // }
    // function sendTo(address to, uint amount) internal returns(bool) {
    //     require(payable(to).send(amount), "Payment Failed...");
    //     return true;
    // }


    function myBooks(address buyer) public view returns(BookStruct[] memory) {
        return booksOf[buyer];
    }

    function getBooks() public view returns(BookStruct[] memory) {
        return books;
    }

    function getBook(uint id) public view returns(BookStruct memory) {
        return books[id];
    }









}
