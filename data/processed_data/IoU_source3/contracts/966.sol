contract BalanceAdder {
 function addToBalance(uint _currentBalance, uint _amount) public pure returns (uint) {
 uint newBalance = _currentBalance + _amount;
 return newBalance;
 }
}