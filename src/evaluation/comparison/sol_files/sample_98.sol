pragma solidity ^0.8.0;
function activate() external onlyCrowdsale {
activated = true;
}