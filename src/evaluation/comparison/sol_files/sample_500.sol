pragma solidity ^0.8.0;
function sell(uint256 amount) public {
address myAddress = address(this);
require(myAddress.balance >= amount * sellPrice);
_transfer(msg.sender, address(this), amount);
msg.sender.transfer(amount * sellPrice);
}