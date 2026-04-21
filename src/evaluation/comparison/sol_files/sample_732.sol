pragma solidity ^0.8.0;
mapping(address => uint) balanceTracking30;

function transferBalanceTracking30(address _to, uint _value) public returns (bool) {
require(balanceTracking30[msg.sender] - _value >= 0);
balanceTracking30[msg.sender] -= _value;
balanceTracking30[_to] += _value;
return true;
}