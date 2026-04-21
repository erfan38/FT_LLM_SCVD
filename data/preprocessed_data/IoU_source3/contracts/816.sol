contract Overflow_add_loop {

 function add_overflow() returns (uint8 _overflow) {
 uint8 sum = 0;
 for(uint8 i = 0; i < 300; i++) {
 sum += 1;
 }
 return sum;
 }
}