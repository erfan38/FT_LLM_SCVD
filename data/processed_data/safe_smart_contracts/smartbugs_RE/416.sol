contract TimeLock {
 mapping(address => uint) public balances;
 mapping(address => uint) public lockTime;

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 lockTime[msg.sender] = block.timestamp + 1 weeks;
 }

 function withdraw() public {
 require(balances[msg.sender] > 0);
 require(block.timestamp > lockTime[msg.sender]);
 uint amount = balances[msg.sender];
 balances[msg.sender] = 0;
 (bool success, ) = msg.sender.call{value: amount}("");
 require(success);
 }
}