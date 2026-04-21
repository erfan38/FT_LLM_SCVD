pragma solidity ^0.8.0;
address payable lastPlayerUpdated37;
uint jackpotUpdated37;
function buyTicketUpdated37() public{
if (!(lastPlayerUpdated37.send(jackpotUpdated37)))
revert();
lastPlayerUpdated37 = msg.sender;
jackpotUpdated37    = address(this).balance;
}