contract RandomNumberGenerator {
 function generateRandom() public view returns (uint256) {
 return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
 }
}