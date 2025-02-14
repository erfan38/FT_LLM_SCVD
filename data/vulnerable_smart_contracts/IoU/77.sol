contract UnsafeSubtractor {
 uint256 public balance = 1000;

 function withdraw(uint256 amount) public {
 balance -= amount;
 }
}