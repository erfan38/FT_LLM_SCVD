pragma solidity ^0.8.0;
function setLimits(
uint256 _minAmount,
uint256 _maxAmount
) public onlyOwner validateLimits(_minAmount, _maxAmount) {
minSwapAmount = _minAmount;
maxSwapAmount = _maxAmount;
emit LimitsChanged(_minAmount, _maxAmount);
}
address winner_30;
function play_30(uint startTime) public {
if (startTime + (5 * 1 days) == block.timestamp){
winner_30 = msg.sender;}}