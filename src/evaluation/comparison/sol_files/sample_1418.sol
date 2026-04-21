pragma solidity ^0.8.0;
function balanceOf(address _owner) public view returns (uint balance) {
return balances[_owner];
}