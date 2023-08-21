//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract PassManager {

    using Counters for Counters.Counter;
    Counters.Counter private _totalPasswords;

    struct PassWordStruct {
        uint256 id;
        string company;
        string username;
        string password;
    }

    mapping(uint256 => PassWordStruct) public allPasswords;

    function createPassword(string memory company, string memory username, string memory password) public {
        _totalPasswords.increment();
        PassWordStruct memory passwords;

        passwords.id = _totalPasswords.current();
        passwords.company = company;
        passwords.username = username;
        passwords.password= password;

        allPasswords[passwords.id] = passwords;
    }


    function updatePassword(uint256 id, string memory username, string memory password) public {
        require(id <= _totalPasswords.current(), "Password enter not exists");

        PassWordStruct storage passwords = allPasswords[id];
        passwords.username = username;
        passwords.password = password;
    }

    function deletePassword(uint256 id) public {
        require(id <= _totalPasswords.current());
        delete allPasswords[id];
    }

    function getAllPasswords() public view returns(PassWordStruct[] memory passwords) {
       passwords = new PassWordStruct[](_totalPasswords.current());

       for(uint256 i = 1; i <= _totalPasswords.current(); i++) {
           passwords[i - 1] = allPasswords[i];
       }
       return passwords;
        
    }


}
