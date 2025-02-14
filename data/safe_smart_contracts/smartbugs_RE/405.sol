contract SimpleToken {
 mapping(address => uint256) public balances;

 function transfer(address _to, uint256 _value) public {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 balances[_to] += _value;
 }
}