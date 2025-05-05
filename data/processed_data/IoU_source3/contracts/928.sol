contract ERC20Token {
 mapping(address => uint256) public balances;
 uint256 public totalSupply;

 function transfer(address to, uint256 amount) public {
 balances[msg.sender] = balances[msg.sender] - amount;
 balances[to] = balances[to] + amount;
 }
}