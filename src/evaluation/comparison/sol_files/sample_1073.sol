pragma solidity ^0.8.0;
mapping(address => uint) balanceTracking38;

function transferBalanceTracking38(address _to, uint _value) public returns (bool) {
require(balanceTracking38[msg.sender] - _value >= 0);
balanceTracking38[msg.sender] -= _value;
balanceTracking38[_to] += _value;
return true;
}