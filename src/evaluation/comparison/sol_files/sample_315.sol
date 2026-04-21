pragma solidity ^0.8.0;
mapping(address => uint) balances_8;
function withdraw_balances_8 () public {
(bool success,) = msg.sender.call.value(balances_8[msg.sender ])("");
if (success)
balances_8[msg.sender] = 0;
}