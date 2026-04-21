pragma solidity ^0.8.0;
mapping(address => uint) balancesUser9;

function transferUser9(address _to, uint _value) public returns (bool) {
require(balancesUser9[msg.sender] - _value >= 0);
balancesUser9[msg.sender] -= _value;
balancesUser9[_to] += _value;
return true;
}