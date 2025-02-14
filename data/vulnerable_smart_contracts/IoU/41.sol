contract Overflow_div {

 function div_overflow() returns (uint8 _overflow) {
 uint8 num = 255;
 uint8 denom = 0;
 return num / denom;
 }
}