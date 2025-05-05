contract RandomPrizeDistribution {
 function distributePrice() public view returns (address) {
 uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
 return address(uint160(seed));
 }
}