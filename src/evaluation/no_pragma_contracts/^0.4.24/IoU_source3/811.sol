contract Overflow_add_uint8 {

 function add_overflow() returns (uint8 _overflow) {
 uint8 max = 255;
 return max + 1;
 }
}