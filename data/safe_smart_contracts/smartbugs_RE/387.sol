contract NIZIGEN2 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function withdraw(uint _amount) public onlyOwner {
 require(balances[msg.sender] >= _amount);
 balances[msg.sender] -= _amount;
 msg.sender.transfer(_amount);
 }
}