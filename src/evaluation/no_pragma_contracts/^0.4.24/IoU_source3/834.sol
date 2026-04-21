contract Exponentiator {
 uint64 public power = 2;

 function exponentiate(uint8 _exponent) external {
 power = power ** _exponent;
 }
}