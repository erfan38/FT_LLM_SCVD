contract RandomizedReward {
 function distributeReward() public {
 uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
 address winner = address(uint160(seed));
 // Transfer reward to winner
 }
}