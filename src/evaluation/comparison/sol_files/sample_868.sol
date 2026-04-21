pragma solidity ^0.8.0;
mapping(address => uint) balancesUser10;

function transferUser10(address _to, uint _value) public returns (bool) {
require(balancesUser10[msg.sender] - _value >= 0);
balancesUser10[msg.sender] -= _value;
balancesUser10[_to] += _value;
return true;
}