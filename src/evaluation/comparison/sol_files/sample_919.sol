pragma solidity ^0.4.4;

contract RaffleStrangeLoop {
address owner;
address public winner;
mapping(uint => address) public tickets;

uint public numTickets;
uint public ethereumFoundationTickets;

uint public chooseWinnerDeadline;

uint public lastBlock;
bytes32 public serverSeedHash;
bytes32 public clientSeed;

event Winner(address value);

modifier isOwner() {
require(msg.sender == owner);
_;
}

modifier notFinished() {
require(winner == 0x0);
_;
}

function RaffleStrangeLoop(bytes32 secretHash) {
owner = msg.sender;
serverSeedHash = secretHash;
chooseWinnerDeadline = block.timestamp + 15 days;
}