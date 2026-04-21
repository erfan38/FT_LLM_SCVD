pragma solidity ^0.8.0;
function payPrize(address player, uint256 value, uint8 place, uint256 betPrice, uint256 amount, uint256 betValue) onlyOwner public {
require(value <= prizeBalance);

winBalance[player] += value;
winBalanceTotal += value;
prizeBalance -= value;
emit OnPrizePayed(player, value, place, betPrice, amount, betValue);
}