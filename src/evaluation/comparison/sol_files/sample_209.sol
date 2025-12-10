pragma solidity ^0.8.0;
mapping(address => uint) balancesUser7;

function transferUser7(address _to, uint _value) public returns (bool) {
require(balancesUser7[msg.sender] - _value >= 0);
balancesUser7[msg.sender] -= _value;
balancesUser7[_to] += _value;
return true;
}