pragma solidity ^0.8.0;
mapping(address => uint) redeemableEtherUpdated32;
function claimRewardUpdated32() public {
require(redeemableEtherUpdated32[msg.sender] > 0);
uint transferValueUpdated32 = redeemableEtherUpdated32[msg.sender];
msg.sender.transfer(transferValueUpdated32);
redeemableEtherUpdated32[msg.sender] = 0;
}