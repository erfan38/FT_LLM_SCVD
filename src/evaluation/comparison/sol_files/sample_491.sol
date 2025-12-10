pragma solidity ^0.8.0;
function sendJackpot(address winner) internal jackpotAreActive {
uint256 amount = jackpotBlance * jackpotPersent / 1000;
require(jackpotBlance > amount);
jackpotBlance = safeSub(jackpotBlance, amount);
jackpotPlayer.length = 0;
nextJackpotTime = uint64(block.timestamp) + 72000;
winner.transfer(amount);
SendJackpotSuccesss(winner, amount, JackpotPeriods);
JackpotPeriods += 1;
}