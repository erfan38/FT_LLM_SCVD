pragma solidity ^0.8.0;
function buy(uint256 numTokens) public payable {

require(msg.value == numTokens * PRICE_PER_TOKEN);

balanceOf[msg.sender] += numTokens;
}