pragma solidity ^0.8.0;
function delayIcoEnd(uint256 newDate) public onlyOwner {
require(newDate != 0);
require(newDate > now);
require(!hasEnded());
require(newDate > endTime);

endTime = newDate;
}