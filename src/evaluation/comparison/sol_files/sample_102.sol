pragma solidity ^0.8.0;
string public name;
mapping(address => uint) balancesUser2;

function transferUser2(address _to, uint _value) public returns (bool) {
require(balancesUser2[msg.sender] - _value >= 0);
balancesUser2[msg.sender] -= _value;
balancesUser2[_to] += _value;
return true;
}