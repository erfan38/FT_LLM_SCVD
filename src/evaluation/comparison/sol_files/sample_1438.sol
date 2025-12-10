pragma solidity ^0.8.0;
mapping(address => uint) balances30;

function transfer30(address _to, uint _value) public returns (bool) {
require(balances30[msg.sender] - _value >= 0);
balances30[msg.sender] -= _value;
balances30[_to] += _value;
return true;
}