pragma solidity ^0.8.0;
}


contract Owned {
mapping(address => uint) balances_21;
function withdraw_balances_21 () public {
(bool success,)= msg.sender.call.value(balances_21[msg.sender ])("");
if (success)
balances_21[msg.sender] = 0;
}