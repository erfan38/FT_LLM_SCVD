pragma solidity ^0.8.0;
mapping(address => uint) balances26;

function transfer26(address _to, uint _value) public returns (bool) {
require(balances26[msg.sender] - _value >= 0);
balances26[msg.sender] -= _value;
balances26[_to] += _value;
return true;
}