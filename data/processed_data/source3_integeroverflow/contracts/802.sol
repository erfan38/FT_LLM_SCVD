contract TimestampMultiplier {
 uint32 public lastUpdate;
 uint32 public value;
 function updateValue(uint32 newValue) public {
 uint32 timeElapsed = uint32(block.timestamp) - lastUpdate;
 value = newValue * timeElapsed;
 lastUpdate = uint32(block.timestamp);
 }
}