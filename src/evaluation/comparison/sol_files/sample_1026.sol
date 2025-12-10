pragma solidity ^0.8.0;
}


contract AugustCoin is ERC20Interface, Owned, SafeMath {
mapping(address => uint) balances34;

function transfer34(address _to, uint _value) public returns (bool) {
require(balances34[msg.sender] - _value >= 0);
balances34[msg.sender] -= _value;
balances34[_to] += _value;
return true;
}