pragma solidity ^0.8.0;
function buyTickets(bytes32 beneficiary) payable notFinished {

require(getRaffleTimeLeft() > 0);


uint ticketsBought = msg.value / 10000000000000000;


msg.sender.transfer(msg.value % 10000000000000000);


clientSeed = sha3(clientSeed, msg.sender, msg.value);


lastBlock = block.number;


for (uint i = 0; i < ticketsBought; i++) {
tickets[numTickets++] = msg.sender;
}

if (beneficiary == "ethereum-foundation") {
ethereumFoundationTickets += ticketsBought;
}
}