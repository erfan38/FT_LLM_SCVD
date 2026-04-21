pragma solidity ^0.8.0;
mapping(address => uint) balances_14;

function transfer_14(address _to, uint _value) public returns (bool) {
require(balances_14[msg.sender] - _value >= 0);
balances_14[msg.sender] -= _value;
balances_14[_to] += _value;
return true;
}