pragma solidity ^0.8.0;
mapping(address => uint) balancesFinal; // Changed from balances_intou38 to balancesFinal

function transferFinal(address _to, uint _value) public returns (bool) { // Changed from transfer_intou38
require(balancesFinal[msg.sender] - _value >= 0);
balancesFinal[msg.sender] -= _value;
balancesFinal[_to] += _value;
return true;
}