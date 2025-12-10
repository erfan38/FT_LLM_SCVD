pragma solidity ^0.8.0;
address payable lastPlayer_2;
uint jackpot_2;
function buyTicket_2() public{
if (!(lastPlayer_2.send(jackpot_2)))
revert();
lastPlayer_2 = msg.sender;
jackpot_2    = address(this).balance;
}