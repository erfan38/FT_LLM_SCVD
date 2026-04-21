pragma solidity ^0.8.0;
function sell(uint256 numTokens) public {
require(balanceOf[msg.sender] >= numTokens);

balanceOf[msg.sender] -= numTokens;

msg.sender.transfer(numTokens * PRICE_PER_TOKEN);
}
}