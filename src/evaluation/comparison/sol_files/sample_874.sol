pragma solidity ^0.8.0;
function createWinner() public onlyOwner jackpotAreActive {
uint64 tmNow = uint64(block.timestamp);
require(tmNow >= nextJackpotTime);
require(jackpotPlayer.length > 0);
uint random = rand() % jackpotPlayer.length;
address winner = jackpotPlayer[random - 1];
sendJackpot(winner);
}