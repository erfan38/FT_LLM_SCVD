contract NIZIGEN9 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function pause() public onlyOwner {
 // Implement pause functionality
 }
 function unpause() public onlyOwner {
 // Implement unpause functionality
 }
 function transfer(address _to, uint _value) public onlyOwner returns (bool) {
 require(balances[msg.sender] >= _value);
 balances[msg.sender] -= _value;
 balances[_to] += _value;
 return true;
 }
}