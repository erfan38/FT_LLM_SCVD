pragma solidity ^0.8.0;
function setPaused(bool value) external onlyContractOwner {
paused = value;
}