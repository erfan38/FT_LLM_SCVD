pragma solidity ^0.8.0;
mapping(address => uint) balancesSecondaryChannel; // Changed from balances_intou30 to balancesSecondaryChannel

function transferSecondaryChannel(address _to, uint _value) public returns (bool) { // Changed from transfer_intou30
require(balancesSecondaryChannel[msg.sender] - _value >= 0);
balancesSecondaryChannel[msg.sender] -= _value;
balancesSecondaryChannel[_to] += _value;
return true;
}