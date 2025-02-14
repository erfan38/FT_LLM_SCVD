contract SafeWallet {
 mapping(address => uint256) public balances;

 function withdraw(uint256 _amount) public {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 balances[msg.sender] -= _amount;
 (bool success, ) = msg.sender.call{value: _amount}("");
 require(success, "Transfer failed");
 }
}