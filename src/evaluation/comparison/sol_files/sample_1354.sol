pragma solidity ^0.8.0;
mapping(address => uint) balancesSecondaryFinal; // Changed from balances_intou26 to balancesSecondaryFinal

function transferSecondaryFinal(address _to, uint _value) public returns (bool) { // Changed from transfer_intou26
require(balancesSecondaryFinal[msg.sender] - _value >= 0);
balancesSecondaryFinal[msg.sender] -= _value;
balancesSecondaryFinal[_to] += _value;
return true;
}