//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.0;

contract PoliceReport {
    uint public reportCount = 0;

    struct reportInfo {
        string name;
        string fatherName;
        string aboutCase;
        uint citizenshipNo;
    }

    mapping(uint => reportInfo) public citizenship;

    function createReport(string memory _name, string memory _fatherName, string memory _aboutCase, uint citizenshipNo) public {
        reportCount++;
        citizenship[citizenshipNo] = reportInfo(_name, _fatherName, _aboutCase, citizenshipNo);
    }
}
