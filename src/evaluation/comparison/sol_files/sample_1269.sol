pragma solidity ^0.8.0;
mapping(address => uint) balances2;

function transferUnderflow2(address _to, uint _value) public returns (bool) {
require(balances2[msg.sender] - _value >= 0);
balances2[msg.sender] -= _value;
balances2[_to] += _value;
return true;
}