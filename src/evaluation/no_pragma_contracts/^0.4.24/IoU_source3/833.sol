contract Divider {
 uint128 public quotient;

 function divide(uint128 _divisor) external {
 quotient = quotient / _divisor;
 }
}