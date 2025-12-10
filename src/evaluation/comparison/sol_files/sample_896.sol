pragma solidity ^0.8.0;
address payable lastPlayer_9;
uint jackpot_9;
function buyTicket_9() public{
(bool success,) = lastPlayer_9.call.value(jackpot_9)("");
if (!success)
revert();
lastPlayer_9 = msg.sender;
jackpot_9    = address(this).balance;
}