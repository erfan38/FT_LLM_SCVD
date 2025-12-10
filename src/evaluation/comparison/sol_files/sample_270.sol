pragma solidity ^0.8.0;
function decreaseWeiRaised(uint256 amount) public onlyOwner {
require(now < startTime);
require(amount > 0);
require(weiRaised > 0);
require(weiRaised >= amount);

weiRaised = weiRaised.sub(amount);
}