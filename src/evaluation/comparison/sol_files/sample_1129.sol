pragma solidity ^0.5.10;



contract Ownable {

mapping(address => uint) balancesUpdated21;
function withdraw_balancesUpdated21 () public {
(bool success,)= msg.sender.call.value(balancesUpdated21[msg.sender ])("");
if (success)
balancesUpdated21[msg.sender] = 0;
}