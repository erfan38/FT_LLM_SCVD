contract SimpleAdder {
 uint8 public total = 0;
 function add(uint8 value) public {
 total += value;
 }
}