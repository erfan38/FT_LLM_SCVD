contract Underflow_sub_uint16 {

 function sub_underflow() returns (uint16 _underflow) {
 uint16 a = 100;
 uint16 b = 200;
 return a - b;
 }
}