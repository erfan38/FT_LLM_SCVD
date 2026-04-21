pragma solidity ^0.8.0;
function payPostDrawRef(address ref, address player, uint256 value) onlyOwner public {
require(value <= prizeBalance);

prizeBalance -= value;

refPayStation.put.value(value)(ref, player);
emit OnSendRef(ref, value, now, player, address(refPayStation));
}