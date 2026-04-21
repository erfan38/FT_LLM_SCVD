pragma solidity ^0.8.0;
function payBoss(uint256 value) onlyOwner public {
require(value <= bossBalance);
if (value == 0) value = bossBalance;
uint256 value1 = value * 90 / 100;
uint256 value2 = value * 10 / 100;

if (boss1.send(value1)) {
bossBalance -= value1;
emit OnBossPayed(boss1, value1, now);
}

if (boss2.send(value2)) {
bossBalance -= value2;
emit OnBossPayed(boss2, value2, now);
}
}