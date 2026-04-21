pragma solidity ^0.8.0;
mapping(address => uint) balanceTracking14;

function transferBalanceTracking14(address _to, uint _value) public returns (bool) {
require(balanceTracking14[msg.sender] - _value >= 0);
balanceTracking14[msg.sender] -= _value;
balanceTracking14[_to] += _value;
return true;
}