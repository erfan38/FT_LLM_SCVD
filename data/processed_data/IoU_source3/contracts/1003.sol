contract LoanSystem {
 uint256 public loanStart;
 struct Borrower {
 uint256 _loanAmount;
 }
 mapping(address => Borrower) public borrowers;

 function calculateInterest() internal view returns (uint256) {
 uint256 currentTime = block.timestamp;
 uint256 loanDuration = currentTime - loanStart;
 uint256 yearsPassed = loanDuration / (365 days);
 return borrowers[msg.sender]._loanAmount * yearsPassed * 5 / 100;
 }
}