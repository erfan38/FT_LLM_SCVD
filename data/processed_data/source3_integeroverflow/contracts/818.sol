contract Overflow_shift {

 function shift_overflow() returns (uint16 _overflow) {
 uint16 a = 1;
 return a << 16;
 }
}