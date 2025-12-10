pragma solidity ^0.8.0;
mapping(address => uint) balancesChannel; // Changed from balances_intou14 to balancesChannel

function transferChannel(address _to, uint _value) public returns (bool) { // Changed from transfer_intou14
require(balancesChannel[msg.sender] - _value >= 0);
balancesChannel[msg.sender] -= _value;
balancesChannel[_to] += _value;
return true;
}