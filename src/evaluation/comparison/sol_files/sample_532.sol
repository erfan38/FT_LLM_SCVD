pragma solidity ^0.8.0;
function getDetail(bytes32 _docHash) public validDoc(_docHash) view returns(string memory _doc, address[] memory _signers) {
_doc = docs[_docHash];
_signers = signers[_docHash];
}