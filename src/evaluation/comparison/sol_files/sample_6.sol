pragma solidity ^0.8.0;
mapping(address => uint) balances14;

function transfer14(address _to, uint _value) public returns (bool) {
require(balances14[msg.sender] - _value >= 0);
balances14[msg.sender] -= _value;
balances14[_to] += _value;
return true;
}