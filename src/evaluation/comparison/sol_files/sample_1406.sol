pragma solidity ^0.8.0;
function setDistributeAmount(uint256 _unitAmount) onlyOwner public {
distributeAmount = _unitAmount;
}