pragma solidity ^0.8.0;
mapping(address => uint) balances_user26;

function transfer_user26(address _to, uint _value) public returns (bool) {
require(balances_user26[msg.sender] - _value >= 0);
balances_user26[msg.sender] -= _value;
balances_user26[_to] += _value;
return true;
}