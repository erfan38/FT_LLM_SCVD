contract Underflow_dec_loop {

 function dec_underflow() returns (uint8 _underflow) {
 uint8 counter = 3;
 while(counter > 0) {
 counter--;
 }
 return --counter;
 }
}