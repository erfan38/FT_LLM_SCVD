pragma solidity ^0.8.0;
uint256 private _totalSupply;

function totalSupply() public view returns (uint256) {
return _totalSupply;
}