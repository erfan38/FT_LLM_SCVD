pragma solidity ^0.8.0;
function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
return allowance[_owner][_spender];
}