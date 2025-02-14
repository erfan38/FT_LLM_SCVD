contract VulnerableVault {
 mapping(address => uint) public balances;

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }

 function withdraw() public {
 uint amount = balances[msg.sender];
 (bool success, ) = msg.sender.call{value: amount}("");
 require(success);
 balances[msg.sender] = 0;
 }
}