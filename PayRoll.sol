//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Payroll {
    address public companyAcc;
    uint public companyBal;
    uint public totalWorkers;
    uint public totalSalary;
    uint public totalPayment;


    mapping(address => bool) workerExist;
    EmployeeStruct[] employees;

    event Paid(
        uint id,
        address indexed from,
        uint totalSalary,
        uint timestamp
    );

    struct EmployeeStruct {
        uint id;
        address worker;
        uint salary;
        uint timestamp;
    }

    modifier ownerOnly() {
        require(msg.sender == companyAcc, "You have to be owner");
        _;
    }


    constructor() {
        companyAcc = msg.sender;
    }


    function addEmployee(address worker, uint salary) public ownerOnly returns(bool) {
        require(salary > 0 ether, "salary must be more than zero");
        require(!workerExist[worker], "Employee Exists...");

        totalWorkers++;
        totalSalary += salary;
        workerExist[worker] = true;

        employees.push(EmployeeStruct(totalWorkers,worker, salary, block.timestamp));

        return true;
    }


    function payEmployees() public ownerOnly returns(bool) {
        require(companyBal >= totalSalary, "Insuffieient Balance ...");

        for(uint i = 0; i < employees.length; i++) {
            payTo(employees[i].worker, employees[i].salary);
        }

        totalPayment++;
        companyBal -= totalSalary;

        emit Paid(totalPayment, companyAcc, totalSalary, block.timestamp);

        return true;

    }

    function fundAccount() public payable returns(bool) {
        require(companyAcc != msg.sender, "You can't fund yourself");
        require(msg.value > 0, "Insufficient Amout");

        companyBal += msg.value;
        return true;
    }

    function getEmployees() public view returns(EmployeeStruct[] memory) {
        return employees;
    }

    function payTo(address to, uint amount) internal returns(bool) {
        (bool succeeded, ) = payable(to).call{value: amount}("");
        require(succeeded, "Payment Failed");
        return true;
    }


}
