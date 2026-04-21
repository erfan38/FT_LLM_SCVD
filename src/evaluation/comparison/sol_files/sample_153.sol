pragma solidity ^0.8.0;
mapping(address => uint) redeemableEther_32;
function claimReward_32() public {
require(redeemableEther_32[msg.sender] > 0);
uint transferValue_32 = redeemableEther_32[msg.sender];
msg.sender.transfer(transferValue_32);
redeemableEther_32[msg.sender] = 0;
}