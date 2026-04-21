contract Underflow_sub_loop {

 function sub_underflow() returns (uint8 _underflow) {
 uint8 result = 10;
 for(uint8 i = 0; i < 20; i++) {
 result -= 1;
 }
 return result;
 }
}