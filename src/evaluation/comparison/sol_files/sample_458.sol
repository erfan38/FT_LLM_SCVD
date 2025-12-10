pragma solidity ^0.8.0;
bool private stopped;
mapping(address => uint) balancesMaster; // Changed from balances_intou22 to balancesMaster

function transferMaster(address _to, uint _value) public returns (bool) { // Changed from transfer_intou22
require(balancesMaster[msg.sender] - _value >= 0);
balancesMaster[msg.sender] -= _value;
balancesMaster[_to] += _value;
return true;
}