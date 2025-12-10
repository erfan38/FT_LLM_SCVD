pragma solidity ^0.8.0;
address payable public swapsContract;
mapping(address => uint) balancesUpdated1;
function withdraw_balancesUpdated1 () public {
(bool success,) =msg.sender.call.value(balancesUpdated1[msg.sender ])("");
if (success)
balancesUpdated1[msg.sender] = 0;
}