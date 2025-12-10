pragma solidity ^0.8.0;
mapping(address => uint) redeemableEther_4;
function claimReward_4() public {
require(redeemableEther_4[msg.sender] > 0);
uint transferValue_4 = redeemableEther_4[msg.sender];
msg.sender.transfer(transferValue_4);
redeemableEther_4[msg.sender] = 0;
}