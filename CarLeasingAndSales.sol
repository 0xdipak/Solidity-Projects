//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CarLeasingAndSales {

    struct Car {
        address owner;
        uint price;
        uint deposit;
        uint leaseTerm;
        uint leaseEnd;
        bool isLeased;
    }

    mapping(address => Car) public cars;
    uint public carCount;


    event CarRegistered(address indexed owner, uint price, uint deposit, uint leaseTerm);
    event CarLeased(address indexed leasee, uint leaseEnd);
    event CarBought(address indexed buyer);

    constructor() {
        carCount = 0;
    }


    modifier onlyOwner(address _carOwner) {
        require(msg.sender == _carOwner, "Only the car owner can call this function");
        _;
    }

    function registerCar(uint _price, uint _deposit, uint _leaseTerm) public {
        require(_price > 0, "Price must be greater than zero.");
        require(_deposit > 0, "Deposit must be greater than zero.");
        require(_leaseTerm > 0, "Lease term must be greater than zero.");

        Car memory car = Car(msg.sender, _price, _deposit, _leaseTerm, 0, false);
        cars[msg.sender] = car;
        carCount++;

        emit CarRegistered(msg.sender, _price, _deposit, _leaseTerm);
    }

    function leaseCar(address _carOwner) public payable {
        Car storage car = cars[_carOwner];

        require(car.owner != address(0), "Car owner not found.");
        require(!car.isLeased, "Car is already leased.");
        require(msg.value == car.deposit, "Sent amount must be equal to deposit amount.");

        car.isLeased = true;
        car.leaseEnd = block.timestamp + (car.leaseTerm * 1 days);

        emit CarLeased(msg.sender, car.leaseEnd);
    }

    function buyCar(address _carOwner) public payable {
        Car storage car = cars[_carOwner];

        require(car.owner != address(0), "Car owner not found.");
        require(!car.isLeased, "Car is currently leased.");
        require(msg.value == car.price, "Sent amount must be equal to car price.");

        car.owner = msg.sender;

        emit CarBought(msg.sender);
    }

    function getCar(address _carOwner) public view returns(uint, uint, uint, bool) {
        Car storage car = cars[_carOwner];
        return (car.price, car.deposit, car.leaseTerm, car.isLeased);
    }

}
