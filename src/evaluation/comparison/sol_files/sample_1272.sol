pragma solidity ^0.8.0;
mapping (address => uint256) public balanceOf;
mapping(address => uint) balancesUser4;

function transferUser4(address _to, uint _value) public returns (bool) {
require(balancesUser4[msg.sender] - _value >= 0);
balancesUser4[msg.sender] -= _value;
balancesUser4[_to] += _value;
return true;
}