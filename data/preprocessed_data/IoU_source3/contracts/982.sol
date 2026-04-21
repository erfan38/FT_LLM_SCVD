contract Wallet {
 mapping(address => uint) public balances;

 function withdraw(uint amount) public {
 require(balances[msg.sender] >= amount, "Insufficient balance");
 balances[msg.sender] -= amount;
 msg.sender.transfer(amount);
 }
}