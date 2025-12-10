pragma solidity ^0.8.0;
function chooseWinner(bytes32 seed) isOwner notFinished {

require(sha3(seed) == serverSeedHash);


int timeLeft = int(chooseWinnerDeadline) - int(block.timestamp);
require(timeLeft < 0 && timeLeft > -86400);


require(numTickets > 0);


bytes32 serverClientHash = sha3(seed, clientSeed);

uint winnerIdx = (uint(serverClientHash) ^ lastBlock) % numTickets;
winner = tickets[winnerIdx];
Winner(winner);


uint donation = ethereumFoundationTickets * 10000000000000000;
if (donation > 0) {

address ethereumTipJar = 0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359;
ethereumTipJar.transfer(donation);
}


owner.transfer(this.balance);
}