pragma solidity ^0.8.0;
function WithdrawPotShare() public
{
MinerData storage m = miners[msg.sender];

require(m.unclaimedPot > 0);
require(m.lastUpdateTime != 0);

uint256 amntToSend = m.unclaimedPot;
m.unclaimedPot = 0;

if(msg.sender.send(amntToSend))
{
m.unclaimedPot = 0;
}
}