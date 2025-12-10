pragma solidity ^0.8.0;
function totalSupply() public view returns (uint) {
return _totalSupply.sub(balances[address(0)]);
}