pragma solidity ^0.8.0;
function allowance(address owner, address spender) public view returns (uint256) {
return _allowances[owner][spender];
}