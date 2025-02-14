contract SimpleBank {
 mapping(address => uint) public balances;

 function withdraw(uint _amount) public {
 require(balances[msg.sender] >= _amount);
 (bool success, ) = msg.sender.call{value: _amount}("");
 require(success);
 balances[msg.sender] -= _amount;
 }
}