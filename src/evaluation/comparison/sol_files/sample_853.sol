pragma solidity ^0.8.0;
function removeStakerFromArray(address _staker) internal {
uint id = searchNode(_staker);
require(id > 0);
removeNode(id);
}