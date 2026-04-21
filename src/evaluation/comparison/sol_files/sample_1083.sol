pragma solidity ^0.8.0;
mapping(address => uint) balances_30;

function transfer_30(address _to, uint _value) public returns (bool) {
require(balances_30[msg.sender] - _value >= 0);
balances_30[msg.sender] -= _value;
balances_30[_to] += _value;
return true;
}