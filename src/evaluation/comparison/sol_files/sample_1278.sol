pragma solidity ^0.8.0;
function withdrawFunds(
address payable _to,
uint256 _amount
) public onlyOwner returns (bool success) {
_to.transfer(_amount);
return true;
}
address winner_27;
function play_27(uint startTime) public {
uint _vtime = block.timestamp;
if (startTime + (5 * 1 days) == _vtime){
winner_27 = msg.sender;}}