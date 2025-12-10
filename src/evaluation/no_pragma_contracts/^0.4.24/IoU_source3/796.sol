contract Multiplier {
 uint16 public result = 1;
 function multiply(uint16 factor) public {
 result *= factor;
 }
}