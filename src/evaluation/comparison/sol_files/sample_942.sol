pragma solidity ^0.8.0;
function buy() public payable {

require(block.timestamp < pubEnd);
require(msg.value > 0);


require(msg.value + totalSold <= maxCap);


uint256 tokenAmount = (msg.value * tokenUnit) / tokenPrice;


require(tokenAmount <= essToken.balanceOf(this));

transferBuy(msg.sender, tokenAmount);
totalSold = totalSold.add(msg.value);
FWDaddrETH.transfer(msg.value);

}