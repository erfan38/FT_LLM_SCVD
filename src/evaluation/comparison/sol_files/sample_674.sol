pragma solidity ^0.8.0;
function getProofHash() public view returns (bytes memory proofHash) {
proofHash = MultiHashWrapper._combineMultiHash(_proofHash);
}