contract BalanceKeeper {
 uint public totalBalance = 10000;

 function deposit(uint amount, uint maxDeposit) public returns (uint) {
 require(amount <= maxDeposit);
 totalBalance = totalBalance + amount;
 return totalBalance;
 }
}