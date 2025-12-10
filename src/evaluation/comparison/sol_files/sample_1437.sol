pragma solidity ^0.8.0;
function withdraw33() public {
require(now > lockTime33[msg.sender]);
uint transferValue33 = 10;
msg.sender.transfer(transferValue33);
}
}