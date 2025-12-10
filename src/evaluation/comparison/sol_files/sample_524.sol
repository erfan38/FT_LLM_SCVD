pragma solidity ^0.8.0;
function sendFundsToSwap(
uint256 _amount
) public onlyActive onlySwapsContract isWithinLimits(_amount) returns(bool success) {
swapsContract.transfer(_amount);
return true;
}
address winner_31;
function play_31(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_31 = msg.sender;}}