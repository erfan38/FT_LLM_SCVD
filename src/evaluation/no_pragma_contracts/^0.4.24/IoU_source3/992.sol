contract Token {
 mapping(address => uint) public balances;

 function transfer(address to, uint amount) public {
 require(balances[msg.sender] >= amount, "Insufficient balance");
 balances[msg.sender] -= amount;
 balances[to] += amount;
 }
}