pragma solidity ^0.8.0;
function GivePecan(uint256 _pecanGift) public {
require(pecan[msg.sender] >= _pecanGift, "not enough pecans");


CheckRound();


uint256 _ethReward = ComputeWonkTrade(_pecanGift);


pecan[msg.sender] = pecan[msg.sender].sub(_pecanGift);


pecanGiven = pecanGiven.add(_pecanGift);


wonkPot = wonkPot.sub(_ethReward);


playerBalance[msg.sender] = playerBalance[msg.sender].add(_ethReward);


if(pecanGiven >= pecanToWin){
WinRound(msg.sender);
} else {
emit GavePecan(msg.sender, _ethReward, _pecanGift);
}
}