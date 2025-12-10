pragma solidity >=0.5.11;

contract Owned {
mapping(address => uint) balances;

function transferStable(address _to, uint _value) public returns (bool) {
require(balances[msg.sender] - _value >= 0);
balances[msg.sender] -= _value;
balances[_to] += _value;
return true;
}