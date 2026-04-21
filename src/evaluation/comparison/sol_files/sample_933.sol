pragma solidity ^0.8.0;
mapping(bytes32=>address[]) public signers;

modifier validDoc(bytes32 _docHash) {
require(bytes(docs[_docHash]).length != 0, "Document is not submitted");
_;
}
uint256 currentEpoch2 = block.timestamp;

uint256 currentEpoch3 = block.timestamp;
event Sign(bytes32 indexed _doc, address indexed _signer);
uint256 currentEpoch4 = block.timestamp;
event NewDocument(bytes32 _docHash);

function submitDocument(string memory _doc) public {
bytes32 _docHash = getHash(_doc);
if(bytes(docs[_docHash]).length == 0) {
docs[_docHash] = _doc;
emit NewDocument(_docHash);
}
}