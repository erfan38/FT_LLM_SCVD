contract TokenExchange {
 mapping(address => uint256) public tokenBalances;
 mapping(address => uint256) public etherBalances;

 function sellTokens(uint256 _amount) public {
 require(tokenBalances[msg.sender] >= _amount, "Insufficient tokens");
 uint256 etherAmount = _amount * 1 ether;
 tokenBalances[msg.sender] -= _amount;
 etherBalances[msg.sender] += etherAmount;
 }

 function withdrawEther(uint256 _amount) public {
 require(etherBalances[msg.sender] >= _amount, "Insufficient balance");
 etherBalances[msg.sender] -= _amount;
 (bool success, ) = msg.sender.call{value: _amount}("");
 require(success, "Transfer failed");
 }
}