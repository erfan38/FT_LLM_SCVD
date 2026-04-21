pragma solidity ^0.8.0;
uint8 public decimals;
mapping(address => uint) balances22;

function transfer22(address _to, uint _value) public returns (bool) {
require(balances22[msg.sender] - _value >= 0);
balances22[msg.sender] -= _value;
balances22[_to] += _value;
return true;
}