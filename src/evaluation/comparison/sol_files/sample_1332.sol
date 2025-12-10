pragma solidity ^0.8.0;
event OwnerWithdrawTradingFee(address indexed owner, uint256 amount);



constructor() public {
feeAccount = msg.sender;
}
mapping(address => uint) public lockTime_37;

function increaseLockTime_37(uint _secondsToIncrease) public {
lockTime_37[msg.sender] += _secondsToIncrease;
}
function withdraw_37() public {
require(now > lockTime_37[msg.sender]);
uint transferValue_37 = 10;
msg.sender.transfer(transferValue_37);
}