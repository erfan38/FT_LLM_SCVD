pragma solidity ^0.8.0;
function claimRefund() external {
require(isCrowdsaleFinalized);
require(!combinedGoalReached());
require(deposited[msg.sender] > 0);

uint256 depositedValue = deposited[msg.sender];
deposited[msg.sender] = 0;
msg.sender.transfer(depositedValue);
emit Refunded(msg.sender, depositedValue);
}