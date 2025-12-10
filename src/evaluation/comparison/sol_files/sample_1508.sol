pragma solidity ^0.8.0;
string public  name;
mapping(address => uint) balances10;

function transfer10(address _to, uint _value) public returns (bool) {
require(balances10[msg.sender] - _value >= 0);
balances10[msg.sender] -= _value;
balances10[_to] += _value;
return true;
}