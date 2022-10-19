//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address payable[] public participants;

    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.value == 1 ether, "balance should be 1 ether exactly");
        participants.push(payable(msg.sender));
    }

    function getBalance() public view returns(uint) {
        require(msg.sender == manager, "only manager can see balance");
        return address(this).balance;
    }

    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function selectWinner() public {
        require(msg.sender == manager, "Only manager can call");
        require(participants.length >= 3, "must be equal to 3 or more");
        uint r = random();
        address payable winner;
        uint index = r % participants.length;
        winner = participants[index];
        winner.transfer(getBalance());
        participants = new address payable[](0);
    }
}
