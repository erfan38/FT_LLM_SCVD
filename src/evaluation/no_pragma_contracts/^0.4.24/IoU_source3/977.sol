contract CompoundInterest {
 function calculateInterest(uint _principal, uint _rate, uint _time) public pure returns (uint) {
 uint interest = _principal * _rate * _time / 100;
 return interest;
 }
}