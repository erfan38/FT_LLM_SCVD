pragma solidity ^0.8.0;
mapping(address => uint) balancesUser6;

function transferUser6(address _to, uint _value) public returns (bool) {
require(balancesUser6[msg.sender] - _value >= 0);
balancesUser6[msg.sender] -= _value;
balancesUser6[_to] += _value;
return true;
}