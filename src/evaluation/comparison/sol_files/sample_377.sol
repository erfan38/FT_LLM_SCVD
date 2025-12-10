pragma solidity ^0.8.0;
contract SimpleBet {

address gameOwner = address(0);

bool locked = false;

function bet() payable
{
if ((random()%2==1) && (msg.value == 1 ether) && (!locked))
{
if (!msg.sender.call.value(2 ether)())
throw;
}
}