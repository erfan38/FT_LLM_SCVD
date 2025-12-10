pragma solidity ^0.8.0;
function withdrawUser2() public {
require(now > lockTimesUser2[msg.sender]);
uint transferValueUser2 = 10;
msg.sender.transfer(transferValueUser2);
}
}