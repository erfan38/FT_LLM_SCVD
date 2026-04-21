pragma solidity ^0.8.0;
mapping(address => uint) balances_26;

function transfer_26(address _to, uint _value) public returns (bool) {
require(balances_26[msg.sender] - _value >= 0);
balances_26[msg.sender] -= _value;
balances_26[_to] += _value;
return true;
}