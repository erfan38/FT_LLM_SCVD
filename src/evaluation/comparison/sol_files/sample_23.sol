pragma solidity ^0.8.0;
function getRefund() notFinished {

int timeLeft = int(chooseWinnerDeadline) - int(block.timestamp);
require(timeLeft < -86400);

uint amountToRefund = 0;
for (uint i = 0; i < numTickets; i++) {
if(tickets[i] == msg.sender) {
amountToRefund += 10000000000000000;
tickets[i] = 0x0;
}
}

msg.sender.transfer(amountToRefund);
}