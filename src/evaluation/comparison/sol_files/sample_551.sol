pragma solidity ^0.8.0;
mapping(address => uint) redeemableEther_25;
function claimReward_25() public {
require(redeemableEther_25[msg.sender] > 0);
uint transferValue_25 = redeemableEther_25[msg.sender];
msg.sender.transfer(transferValue_25);
redeemableEther_25[msg.sender] = 0;
}