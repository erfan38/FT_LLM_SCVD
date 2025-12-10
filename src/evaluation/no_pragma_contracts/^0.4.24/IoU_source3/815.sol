contract Overflow_exp_uint32 {

 function exp_overflow() returns (uint32 _overflow) {
 uint32 base = 2;
 uint32 exponent = 31;
 return base ** exponent;
 }
}