contract SafeAdder {
 uint256 public total = 0;
 function add(uint256 value) public {
 require(total + value >= total, 'Overflow detected');
 total += value;
 }
}