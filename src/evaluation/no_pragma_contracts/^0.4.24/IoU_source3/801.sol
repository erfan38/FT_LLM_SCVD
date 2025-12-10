contract UnsafeDivider {
 uint8 public value = 100;
 function divide(uint8 divisor) public {
 value /= divisor;
 }
}