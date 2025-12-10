contract Subtractor {
 int16 public value;

 function subtract(int16 _amount) external {
 value = value - _amount;
 }
}