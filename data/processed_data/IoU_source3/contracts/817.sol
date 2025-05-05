contract Underflow_mul {

 function mul_underflow() returns (int8 _underflow) {
 int8 a = -128;
 int8 b = -1;
 return a * b;
 }
}