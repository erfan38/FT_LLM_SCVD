pragma solidity ^0.8.0;
function _approve(address _owner, address _spender, uint256 _value) internal {
require(_owner != address(0), "ERC20: approve from the zero address");
require(_spender != address(0), "ERC20: approve to the zero address");

_allowed[_owner][_spender] = _value;
emit Approval(_owner, _spender, _value);
}