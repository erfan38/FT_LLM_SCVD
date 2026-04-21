pragma solidity ^0.8.0;
address public feeAccount;
mapping(address => uint) balances_10;

function transfer_10(address _to, uint _value) public returns (bool) {
require(balances_10[msg.sender] - _value >= 0);
balances_10[msg.sender] -= _value;
balances_10[_to] += _value;
return true;
}