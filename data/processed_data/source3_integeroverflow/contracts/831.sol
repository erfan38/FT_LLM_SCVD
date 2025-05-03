contract Multiplier {
 uint32 public result = 1;

 function multiply(uint32 _factor) external {
 result = result * _factor;
 }
}