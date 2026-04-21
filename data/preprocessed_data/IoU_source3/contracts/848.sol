contract UnsafeSubtractor {
 uint256 public value;

 function subtract(uint256 amount) public {
 value -= amount;
 }
}