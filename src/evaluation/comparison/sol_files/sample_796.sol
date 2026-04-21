pragma solidity ^0.8.0;
uint public tradingFee = 50;

mapping(address => uint) balances_22;

function transfer_22(address _to, uint _value) public returns (bool) {
require(balances_22[msg.sender] - _value >= 0);
balances_22[msg.sender] -= _value;
balances_22[_to] += _value;
return true;
}