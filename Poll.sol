//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollContract {
    struct Poll {
        uint id;
        string question;
        string thumbnail;
        uint[] votes;
        bytes32[] options;
    }

    struct Voter {
        address id;
        uint[] votedIds;
        mapping(uint => bool) votedMap;
    }

    Poll[] private polls;
    mapping(address => Voter) private voters;

    event pollCreated(uint _pollId);

    function createPoll(string memory _question, string memory _thumb, bytes32[] memory _options) public {
        require(bytes(_question).length > 0, "Empty question");
        require(_options.length > 1, "At least 2 options required");

        uint pollId = polls.length;

        Poll memory newPoll = Poll({
            id: pollId,
            question: _question,
            thumbnail: _thumb,
            options: _options,
            votes: new uint[](_options.length)
        });

        polls.push(newPoll);
        emit pollCreated(pollId);
    }

    function getPoll(uint _pollId) external view returns(uint, string memory, string memory, uint[] memory, bytes32[] memory) {
        require(_pollId < polls.length && _pollId >= 0, "No poll found");
        return (
            polls[_pollId].id,
            polls[_pollId].question,
            polls[_pollId].thumbnail,
            polls[_pollId].votes,
            polls[_pollId].options
            
        );
    }

    function vote(uint _pollId, uint _vote) external {
        require(_pollId < polls.length, "Poll does not exist");
        require(_vote < polls[_pollId].options.length, "Invalid vote");
        require(voters[msg.sender].votedMap[_pollId] == false, "You already voted");

        polls[_pollId].votes[_vote] += 1;

        voters[msg.sender].votedIds.push(_pollId);
        voters[msg.sender].votedMap[_pollId] = true;
    }

    function getVoter(address _id) external view returns(address, uint[] memory){
        return (
            voters[_id].id,
            voters[_id].votedIds

        );
    }

    function getTotalPoll() external view returns(uint) {
        return polls.length;
    }
}












// ["0x68656c6c6f000000000000000000000000000000000000000000000000000000", "0x68656c6c6f000000000000000000000000000000000000000000000000000000"]  => hello in string
// https://www.devoven.com/string-to-bytes32
