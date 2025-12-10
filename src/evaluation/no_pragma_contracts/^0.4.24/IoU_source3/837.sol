contract LoopCounter {
 uint8 public loopCount;

 function runLoop(uint8 _times) external {
 for (uint8 i = 0; i < _times; i++) {
 loopCount++;
 }
 }
}