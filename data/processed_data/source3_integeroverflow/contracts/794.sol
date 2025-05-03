contract TokenBalance {
 mapping(address => uint8) public balances;
 function transfer(address to, uint8 amount) public {
 balances[msg.sender] -= amount;
 balances[to] += amount;
 }
}