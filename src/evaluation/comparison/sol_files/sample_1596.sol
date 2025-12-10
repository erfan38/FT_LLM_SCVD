pragma solidity ^0.8.0;
function signDocument(bytes32 _docHash) public validDoc(_docHash){
address[] storage _signers = signers[_docHash];
for(uint i = 0; i < _signers.length; i++) {
if(_signers[i] == msg.sender) return;
}
_signers.push(msg.sender);
}