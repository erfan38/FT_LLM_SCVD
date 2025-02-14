contract VulnerableWallet {
 mapping(address => uint256) public balances;

 function withdraw(uint256 _amount) public {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 (bool success, ) = msg.sender.call{value: _amount}("");
 require(success, "Transfer failed");
 balances[msg.sender] -= _amount;
 }
}