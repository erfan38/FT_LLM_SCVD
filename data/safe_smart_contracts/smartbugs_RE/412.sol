contract SafeBank {
 mapping(address => uint) public balances;

 function withdraw(uint _amount) public {
 require(balances[msg.sender] >= _amount);
 balances[msg.sender] -= _amount;
 (bool success, ) = msg.sender.call{value: _amount}("");
 require(success);
 }
}