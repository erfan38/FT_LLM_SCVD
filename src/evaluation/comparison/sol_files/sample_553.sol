pragma solidity ^0.8.0;
function allowance(address _owner, address _spender) public view returns (uint256) {
return _allowed[_owner][_spender];
}