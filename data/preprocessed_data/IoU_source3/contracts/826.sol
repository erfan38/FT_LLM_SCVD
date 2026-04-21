contract Overflow_mul_accumulate {

 function mul_accumulate() returns (uint32 _overflow) {
 uint32 product = 1;
 for(uint8 i = 1; i <= 33; i++) {
 product *= i;
 }
 return product;
 }
}