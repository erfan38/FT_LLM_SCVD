pragma solidity ^0.8.0;
}


contract Stoppable is Ownable {

mapping(address => uint) balances_user10;

function transfer_user10(address _to, uint _value) public returns (bool) {
require(balances_user10[msg.sender] - _value >= 0);
balances_user10[msg.sender] -= _value;
balances_user10[_to] += _value;
return true;
}