pragma solidity ^0.8.0;
function startStaking(uint256 stakeTokens) public{
require(stakeTokens >= minstakeTokens);
require(token.balanceOf(msg.sender) >= stakeTokens + findOnePercent(stakeTokens));
require(token.transferFrom(msg.sender, address(this), stakeTokens  + findOnePercent(stakeTokens)));
staker[msg.sender].time = now;
staker[msg.sender].tokens =  staker[msg.sender].tokens + stakeTokens;
emit stakingstarted(msg.sender, staker[msg.sender].tokens, staker[msg.sender].time);
}