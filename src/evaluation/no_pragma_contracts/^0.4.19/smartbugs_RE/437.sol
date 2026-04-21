contract EtherVault {
 mapping(address => uint) private balances;

 function withdraw(uint amount) public {
 require(balances[msg.sender] >= amount);
 balances[msg.sender] -= amount;
 (bool success, ) = msg.sender.call{value: amount}("");
 require(success, "Transfer failed.");
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }
}