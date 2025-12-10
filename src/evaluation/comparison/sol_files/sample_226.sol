pragma solidity ^0.8.0;
function kill() external onlyContractOwner {
selfdestruct(owner);
}