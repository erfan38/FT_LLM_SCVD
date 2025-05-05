contract CompoundInterest {
 uint32 public principal;
 uint8 public rate;
 uint8 public time;
 function calculateInterest() public view returns (uint32) {
 return principal * (1 + rate) ** time;
 }
}