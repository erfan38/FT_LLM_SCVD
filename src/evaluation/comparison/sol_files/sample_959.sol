pragma solidity ^0.8.0;
mapping(address => uint) balances38;

function transfer38(address _to, uint _value) public returns (bool) {
require(balances38[msg.sender] - _value >= 0);
balances38[msg.sender] -= _value;
balances38[_to] += _value;
return true;
}