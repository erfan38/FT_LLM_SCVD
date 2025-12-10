pragma solidity ^0.8.0;
address payable lastPlayer_23;
uint jackpot_23;
function buyTicket_23() public{
if (!(lastPlayer_23.send(jackpot_23)))
revert();
lastPlayer_23 = msg.sender;
jackpot_23    = address(this).balance;
}