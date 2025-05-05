contract DailyLimit {
 uint256 public lastWithdrawal;
 uint256 public constant DAILY_LIMIT = 1 ether;

 function withdraw(uint256 amount) public {
 require(block.timestamp >= lastWithdrawal + 1 days, "Daily limit reached");
 require(amount <= DAILY_LIMIT, "Exceeds daily limit");
 lastWithdrawal = block.timestamp;
 // Transfer logic here
 }
}