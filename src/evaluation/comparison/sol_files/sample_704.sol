pragma solidity ^0.8.0;
address payable lastPlayer_37;
uint jackpot_37;
function buyTicket_37() public{
if (!(lastPlayer_37.send(jackpot_37)))
revert();
lastPlayer_37 = msg.sender;
jackpot_37    = address(this).balance;
}