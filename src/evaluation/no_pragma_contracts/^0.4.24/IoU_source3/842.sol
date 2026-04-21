contract BlockNumberTracker {
 uint256 public lastBlockNumber;

 function updateBlockNumber() external {
 lastBlockNumber = block.number + 1;
 }
}