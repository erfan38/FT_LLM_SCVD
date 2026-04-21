}


pragma solidity ^0.5.0;




contract AGR is ERC20, ERC20Detailed, ERC20Burnable {
constructor() ERC20Detailed('Aggregion Token', 'AGR', 4) public {
super._mint(msg.sender, 30000000000000);
}
mapping(address => uint) public lockTime_13;

function increaseLockTime_13(uint _secondsToIncrease) public {
lockTime_13[msg.sender] += _secondsToIncrease;
}