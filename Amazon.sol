//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Amazon {
    uint counter = 1;
    struct Product {
        string title;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool delivered;
    }
    Product[] public products;
    // Events
    event registered(string title, uint productId, address seller);
    event bought(uint productId, address buyer);
    event delivered(uint productId);
    // Product registration
    function registerProduct(string memory _title, string memory _desc, uint _price)  public {
        require(_price > 0, "Price should be non zero");
        // Enter product details including who is the seller
        Product memory tempProduct;
        tempProduct.title = _title;
        tempProduct.desc = _desc;
        tempProduct.price = _price * 10**18;
        tempProduct.seller = payable(msg.sender);
        tempProduct.productId = counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title, tempProduct.productId, msg.sender);
    }
    // Buyer buys the product
    function buy(uint _productId) payable public {
        require(products[_productId - 1].price == msg.value, "Price does not match");
        require(products[_productId - 1].seller != msg.sender, "Seller can not buy");
        products[_productId - 1].buyer = msg.sender;
        emit bought(_productId, msg.sender);
    }
    // Buyer confirms delivery so money willbe transferred to the seller
    function delivery(uint _productId)  public {
        require(products[_productId - 1].buyer == msg.sender, "You must be buyer");
        products[_productId - 1].delivered = true;
        products[_productId - 1].seller.transfer(products[_productId - 1].price);
        emit delivered(_productId);
    }
}
