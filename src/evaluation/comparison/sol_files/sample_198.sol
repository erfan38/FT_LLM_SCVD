pragma solidity ^0.8.0;
event ProofHashSet(address caller, bytes proofHash);


function _setProofHash(bytes memory proofHash) internal {
_proofHash = MultiHashWrapper._splitMultiHash(proofHash);
emit ProofHashSet(msg.sender, proofHash);
}