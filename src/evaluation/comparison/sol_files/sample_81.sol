pragma solidity ^0.8.0;
mapping(address => uint) balances_38;

function transfer_38(address _to, uint _value) public returns (bool) {
require(balances_38[msg.sender] - _value >= 0);
balances_38[msg.sender] -= _value;
balances_38[_to] += _value;
return true;
}