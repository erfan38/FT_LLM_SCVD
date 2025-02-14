contract UnsafeExchange {
 mapping(address => uint) public tokens;
 mapping(address => uint) public ethBalances;

 function sellTokens(uint amount) public {
 require(tokens[msg.sender] >= amount);
 uint ethAmount = amount * 10**18;
 tokens[msg.sender] -= amount;
 msg.sender.call{value: ethAmount}("");
 ethBalances[msg.sender] += ethAmount;
 }
}