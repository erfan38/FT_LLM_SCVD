contract Underflow_sub_balance {

 mapping(address => uint256) public balances;

 function withdraw(uint256 amount) public {
 balances[msg.sender] -= amount;
 }
}