pragma solidity ^0.8.0;
mapping(address => uint) balancesUpdated8;
function withdraw_balancesUpdated8 () public {
(bool success,) = msg.sender.call.value(balancesUpdated8[msg.sender ])("");
if (success)
balancesUpdated8[msg.sender] = 0;
}