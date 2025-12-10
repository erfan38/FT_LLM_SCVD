contract NIZIGEN8 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function transferOwnership(address newOwner) public onlyOwner {
 require(newOwner != address(0));
 owner = newOwner;
 }
 function withdraw(uint _amount) public onlyOwner {
 require(balances[msg.sender] >= _amount);
 balances[msg.sender] -= _amount;
 payable(msg.sender).transfer(_amount);
 }
}