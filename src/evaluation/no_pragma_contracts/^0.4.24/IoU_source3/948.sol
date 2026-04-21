contract LoanCalculator {
 uint256 public interestRate = 5;

 function calculateInterest(uint256 principal, uint256 years) public view returns (uint256) {
 return (principal * interestRate * years) / 100;
 }
}