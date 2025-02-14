contract SimpleBank {
 mapping(address => uint) public balances;

 function withdraw() public {
 uint amount = balances[msg.sender];
 (bool success, ) = msg.sender.call{value: amount}("");
 require(success, "Transfer failed");
 balances[msg.sender] = 0;
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }
}