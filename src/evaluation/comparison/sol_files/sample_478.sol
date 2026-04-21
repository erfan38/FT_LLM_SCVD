pragma solidity ^0.8.0;
function withdrawWin() public {
require(winBalance[msg.sender] > 0);
uint256 value = winBalance[msg.sender];
winBalance[msg.sender] = 0;
winBalanceTotal -= value;
msg.sender.transfer(value);
emit OnWithdrawWin(msg.sender, value);
}