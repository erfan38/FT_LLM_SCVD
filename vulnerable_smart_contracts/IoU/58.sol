contract Counter {
 uint8 public count;

 function increment() external {
 count = count + 1;
 }
}