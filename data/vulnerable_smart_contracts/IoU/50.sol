contract Overflow_mul_large {

 function mul_overflow() returns (uint128 _overflow) {
 uint128 a = 264;
 uint128 b = 264;
 return a * b;
 }
}