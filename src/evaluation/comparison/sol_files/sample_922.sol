pragma solidity ^0.8.0;
function _transfer(address _from, address _to, uint _value) internal {
require (_to != address(0x0));
require (balanceOf[_from] >= _value);
require (balanceOf[_to] + _value >= balanceOf[_to]);
require(!frozenAccount[_from]);
require(!frozenAccount[_to]);
balanceOf[_from] -= _value;
balanceOf[_to] += _value;
emit Transfer(_from, _to, _value);
}