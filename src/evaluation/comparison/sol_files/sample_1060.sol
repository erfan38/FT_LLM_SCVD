pragma solidity ^0.8.0;
function redeem() public{
require(!lock);
require(!staker[msg.sender].redeem);
require(staker[msg.sender].time + stakeTime <= now);
require(token.transfer(msg.sender,staker[msg.sender].tokens));
require(token.transferFrom(owner, msg.sender ,staker[msg.sender].tokens * stakePercentage * 100 / 10000));
emit tokensRedeemed(msg.sender, staker[msg.sender].tokens, staker[msg.sender].tokens * stakePercentage * 100 / 10000);
staker[msg.sender].redeem = true;
staker[msg.sender].tokens = 0;
}