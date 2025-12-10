pragma solidity ^0.8.0;
function withdrawFlexible33() public {
require(now > flexibleLockTime33[msg.sender]);
uint transferValue33 = 10;
msg.sender.transfer(transferValue33);
}
}