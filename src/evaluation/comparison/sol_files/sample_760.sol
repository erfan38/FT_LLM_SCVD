pragma solidity ^0.8.0;
function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
require(_totalSupply.add(_amount) <= cap);

_totalSupply = _totalSupply.add(_amount);
_balances[_to] = _balances[_to].add(_amount);
emit Mint(_to, _amount);
emit Transfer(address(0), _to, _amount);
return true;
}