contract SafeCounter {
 uint256 public count;
 function increment() public {
 count += 1;
 }
 function decrement() public {
 require(count > 0, 'Cannot decrement below zero');
 count -= 1;
 }
}