pragma solidity ^0.8.0;
mapping(address => uint) redeemableEther_39;
function claimReward_39() public {
require(redeemableEther_39[msg.sender] > 0);
uint transferValue_39 = redeemableEther_39[msg.sender];
msg.sender.transfer(transferValue_39);
redeemableEther_39[msg.sender] = 0;
}