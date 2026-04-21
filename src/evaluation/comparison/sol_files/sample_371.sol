pragma solidity ^0.8.0;
function startBet(uint _bet) public defcon3 returns(uint betId) {
require(userBank[msg.sender] >= _bet);
require(_bet > 0);
userBank[msg.sender] = (userBank[msg.sender]).sub(_bet);
uint convertedAddr = uint(msg.sender);
uint combinedBet = convertedAddr.add(_bet)*7;
BetBank memory betBank = BetBank({
bet: bytes32(combinedBet),
owner: msg.sender
});

betId = betBanks.push(betBank).sub(1);
}