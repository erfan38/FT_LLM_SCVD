pragma solidity ^0.8.0;
address payable lastPlayer_30;
uint jackpot_30;
function buyTicket_30() public{
if (!(lastPlayer_30.send(jackpot_30)))
revert();
lastPlayer_30 = msg.sender;
jackpot_30    = address(this).balance;
}