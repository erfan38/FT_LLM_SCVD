contract BlockCounter {
 function calculateBlocks(uint _startBlock, uint _endBlock) public pure returns (uint) {
 uint blocksPassed = _endBlock - _startBlock;
 return blocksPassed;
 }
}