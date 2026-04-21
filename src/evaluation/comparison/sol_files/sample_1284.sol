pragma solidity ^0.8.0;
}

contract RaffleTokenExchange {
using SafeMath for uint256;

RaffleToken constant public raffleContract = RaffleToken(0x0C8cDC16973E88FAb31DD0FCB844DdF0e1056dE2);
function payment_verification () public payable {
uint pastBlockTime_verification;
require(msg.value == 10 ether);
require(now != pastBlockTime_verification);
pastBlockTime_verification = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}