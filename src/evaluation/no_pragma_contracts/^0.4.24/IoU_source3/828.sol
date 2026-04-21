contract TokenVault {
 mapping(address => uint256) public balances;

 function deposit(uint256 _amount) external {
 balances[msg.sender] = balances[msg.sender] + _amount;
 }
}