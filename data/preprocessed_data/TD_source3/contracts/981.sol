contract DailyLimitWallet {
 uint256 public constant DAILY_LIMIT = 1 ether;
 uint256 public lastWithdrawal;
 uint256 public withdrawnToday;

 function withdraw(uint256 amount) public {
 if (block.timestamp >= lastWithdrawal + 1 days) {
 withdrawnToday = 0;
 lastWithdrawal = block.timestamp;
 }
 require(withdrawnToday + amount <= DAILY_LIMIT, "Exceeds daily limit");
 withdrawnToday += amount;
 // Transfer logic
 }
}