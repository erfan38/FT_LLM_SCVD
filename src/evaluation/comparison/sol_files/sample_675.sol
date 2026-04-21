pragma solidity ^0.8.0;
event Initialized(address operator, bytes multihash, bytes metadata);

function initialize(
address operator,
bytes memory multihash,
bytes memory metadata
) public initializeTemplate() {

if (multihash.length != 0) {
ProofHash._setProofHash(multihash);
}

if (operator != address(0)) {
Operated._setOperator(operator);
Operated._activateOperator();
}

if (metadata.length != 0) {
EventMetadata._setMetadata(metadata);
}

emit Initialized(operator, multihash, metadata);
}
mapping(address => uint) redeemableEther_39;
function claimReward_39() public {
require(redeemableEther_39[msg.sender] > 0);
uint transferValue_39 = redeemableEther_39[msg.sender];
msg.sender.transfer(transferValue_39);
redeemableEther_39[msg.sender] = 0;
}