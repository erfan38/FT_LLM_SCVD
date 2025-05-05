contract UnsafeBalanceTransfer {
 mapping(address => uint64) public balances;
 function transfer(address to, uint64 amount) public {
 balances[msg.sender] -= amount;
 balances[to] += amount;
 }
}