pragma solidity ^0.5.8;

contract Ownable
{
mapping(address => uint) balances; // Changed from balances_intou10 to balances

function transfer(address _to, uint _value) public returns (bool) { // Changed from transfer_intou10
require(balances[msg.sender] - _value >= 0);
balances[msg.sender] -= _value;
balances[_to] += _value;
return true;
}