contract Underflow_dec_uint8 {

 function dec_underflow() returns (uint8 _underflow) {
 uint8 min = 0;
 return --min;
 }
}