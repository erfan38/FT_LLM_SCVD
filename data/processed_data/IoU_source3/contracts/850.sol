contract SimpleCounter {
 uint8 public count = 0;

 function increment() public {
 count++;
 }

 function decrement() public {
 count--;
 }
}