pragma solidity ^0.8.0;
function increaseWeiRaised(uint256 amount) public onlyOwner {
require(now < startTime);
require(amount > 0);
require(weiRaised.add(amount) <= hardCap);

weiRaised = weiRaised.add(amount);
}