pragma solidity ^0.8.0;
function changeFeeOwner(address _feeOwner) onlyOwner public {
require(_feeOwner != feeOwner && _feeOwner != address(0));
feeOwner = _feeOwner;
}