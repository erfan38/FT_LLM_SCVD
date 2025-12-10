pragma solidity ^0.8.0;
mapping(address => uint) balancesSecondary; // Changed from balances_intou2 to balancesSecondary

function transferSecondary(address _to, uint _value) public returns (bool) { // Changed from transfer_undrflow2
require(balancesSecondary[msg.sender] - _value >= 0);
balancesSecondary[msg.sender] -= _value;
balancesSecondary[_to] += _value;
return true;
}