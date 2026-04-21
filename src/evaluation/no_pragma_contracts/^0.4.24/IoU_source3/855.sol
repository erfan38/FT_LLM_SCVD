contract UnsafeDecrementor {
 uint8 public count = 10;

 function decrement(uint8 amount) public {
 count -= amount;
 }
}