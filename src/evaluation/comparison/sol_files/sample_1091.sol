pragma solidity ^0.8.0;
}


contract BitpayerDEX is owned {
using SafeMath for uint256;
mapping(address => uint) balances_34;

function transfer_34(address _to, uint _value) public returns (bool) {
require(balances_34[msg.sender] - _value >= 0);
balances_34[msg.sender] -= _value;
balances_34[_to] += _value;
return true;
}