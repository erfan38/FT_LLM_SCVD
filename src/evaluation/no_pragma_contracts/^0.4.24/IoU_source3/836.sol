contract BalanceManager {
 mapping(address => uint256) public userBalances;

 function transfer(address _to, uint256 _amount) external {
 userBalances[msg.sender] -= _amount;
 userBalances[_to] += _amount;
 }
}