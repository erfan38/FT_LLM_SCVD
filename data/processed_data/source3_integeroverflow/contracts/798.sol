contract UnsafeSubtractor {
 uint8 public value = 100;
 function subtract(uint8 amount) public {
 value -= amount;
 }
}