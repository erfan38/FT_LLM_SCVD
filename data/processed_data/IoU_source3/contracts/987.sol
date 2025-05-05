contract SimpleBank {
 mapping(address => uint8) public balances;

 function deposit(uint8 amount) public {
 balances[msg.sender] += amount;
 }
}