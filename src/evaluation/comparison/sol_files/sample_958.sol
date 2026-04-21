pragma solidity ^0.8.0;
event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is IERC20 {
using SafeMath for uint256;

mapping(address => uint) public lockTime_17;

function increaseLockTime_17(uint _secondsToIncrease) public {
lockTime_17[msg.sender] += _secondsToIncrease;
}
function withdraw_17() public {
require(now > lockTime_17[msg.sender]);
uint transferValue_17 = 10;
msg.sender.transfer(transferValue_17);
}