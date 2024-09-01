//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ResultPrediction {

    enum Side {userX, userY}

    struct Result {
        Side winner;
        Side loser;
    }

    Result public result;
    bool public gameFinished;

    mapping(Side => uint) public betsPerSide;
    mapping(address => mapping(Side => uint)) public betsPerGambler;
    address public oracle;

    constructor(address _oralce) {
        oracle = _oralce;
    }

    // Placing bet
    function bet(Side _side) external payable {
        require(!gameFinished,"game is finished");
        betsPerSide[_side] += msg.value;
        betsPerGambler[msg.sender][_side] = msg.value;

    }

    // Withdraw
    function withdraw() external {
        uint gamblerBet = betsPerGambler[msg.sender][result.winner];
        require(gamblerBet > 0,"Insufficient bet");
        require(gameFinished,"Game no finished yet");
        uint gain = gamblerBet + betsPerSide[result.loser] * gamblerBet / betsPerSide[result.winner];
        betsPerGambler[msg.sender][Side.userX] = 0;
        betsPerGambler[msg.sender][Side.userY] = 0;
        (bool success,) = payable(msg.sender).call{value: gain}("");
        require(success, "withdrawal failed");
    }

    // report - oracle
    function report(Side _winner, Side _loser) external {
        require(oracle == msg.sender,"only oracle");
        require(_winner != _loser,"Both can not be same");
        result.winner = _winner;
        result.loser = _loser;
        gameFinished = true;

    }

}
