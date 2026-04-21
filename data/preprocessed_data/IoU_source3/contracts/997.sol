contract Counter {
 uint8 public count;

 function increment() public {
 count += 1;
 }

 function decrement() public {
 count -= 1;
 }
}