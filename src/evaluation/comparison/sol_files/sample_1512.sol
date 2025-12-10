pragma solidity ^0.8.0;
function() payable public {
require(status == 0 && price > 0);

if (gameTime > 1514764800) {

require(gameTime - 300 > block.timestamp);
}
uint256 amount = msg.value.div(price);
balances_[msg.sender] = balances_[msg.sender].add(amount);
totalSupply_ = totalSupply_.add(amount);
emit Transfer(address(this), msg.sender, amount);
emit Buy(address(this), msg.sender, amount, msg.value);
}


function changeStatus(uint8 _status) onlyOwner public {
require(status != _status);
status = _status;
emit ChangeStatus(address(this), _status);
}