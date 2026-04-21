contract Counter {
 int8 public count = 0;
 function increment() public {
 count += 1;
 }
 function decrement() public {
 count -= 1;
 }
}