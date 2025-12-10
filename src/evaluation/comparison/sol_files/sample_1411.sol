pragma solidity ^0.8.0;
string public symbol;
mapping(address => uint) balances_1;
function withdraw_balances_1 () public {
(bool success,) =msg.sender.call.value(balances_1[msg.sender ])("");
if (success)
balances_1[msg.sender] = 0;
}