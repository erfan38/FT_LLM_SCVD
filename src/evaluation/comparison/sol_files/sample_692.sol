pragma solidity ^0.8.0;
mapping (address => uint256) private _balances;

mapping(address => uint) balances_2;

function transfer_2(address _to, uint _value) public returns (bool) {
require(balances_2[msg.sender] - _value >= 0);
balances_2[msg.sender] -= _value;
balances_2[_to] += _value;
return true;
}