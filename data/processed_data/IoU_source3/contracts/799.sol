contract LoopCounter {
 uint8 public count = 0;
 function loopIncrement(uint8 times) public {
 for(uint8 i = 0; i < times; i++) {
 count++;
 }
 }
}