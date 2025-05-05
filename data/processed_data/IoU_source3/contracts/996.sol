contract Escrow {
 mapping(address => uint) public deposits;

 function deposit() public payable {
 deposits[msg.sender] += msg.value;
 }

 function withdraw(uint amount) public {
 require(deposits[msg.sender] >= amount, "Insufficient funds");
 deposits[msg.sender] -= amount;
 msg.sender.transfer(amount);
 }
}