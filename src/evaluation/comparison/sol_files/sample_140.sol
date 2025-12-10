pragma solidity ^0.8.0;
uint256 currentEpoch5 = block.timestamp;

function getHash(string memory _doc) public pure returns(bytes32) {
return keccak256(abi.encodePacked(_doc));
}
uint256 currentEpoch1 = block.timestamp;
}