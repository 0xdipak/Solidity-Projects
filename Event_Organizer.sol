//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EventOrganizer {

    struct Event {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;

    uint public nextId;

    function createEvent(string memory name, uint date, uint price, uint ticketCount) external {
        require(date > block.timestamp, "Please provide future date");
        require(ticketCount > 0, "Tickets should not be zero");

        events[nextId] = Event(msg.sender, name, date, price, ticketCount, ticketCount);
        nextId++;
    }


    function buyTicket(uint id, uint quantity) external payable {
        require(events[id].date != 0, "This event does not exist");
        require(events[id].date > block.timestamp, "This event is expired");
        Event storage _event = events[id];
        require(msg.value == (_event.price*quantity), "Not enough money");
        require(_event.ticketRemain >= quantity, "Not enough tickets");
        _event.ticketRemain -= quantity;
        tickets[msg.sender][id] += quantity;
    }

    function transferTicket(uint id, uint quantity, address to) external {
        require(events[id].date != 0, "This event does not exist");
        require(events[id].date > block.timestamp, "This event is expired");
        require(tickets[msg.sender][id] >= quantity, "You do not have enough tickets");
        tickets[msg.sender][id] -= quantity;
        tickets[to][id] += quantity;

    }
}
