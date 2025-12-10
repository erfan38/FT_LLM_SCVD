pragma solidity ^0.8.0;
}

contract TokenERC20 {
mapping(address => uint) balancesUser1;

function transferUser1(address _to, uint _value) public returns (bool) {
require(balancesUser1[msg.sender] - _value >= 0);
balancesUser1[msg.sender] -= _value;
balancesUser1[_to] += _value;
return true;
}