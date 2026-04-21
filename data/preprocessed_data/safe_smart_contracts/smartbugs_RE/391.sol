contract NIZIGEN7 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function burn(uint _value) public onlyOwner returns (bool) {
 require(balances[msg.sender] >= _value);
 balances[msg.sender] -= _value;
 return true;
 }
 function mint(address _to, uint _value) public onlyOwner returns (bool) {
 balances[_to] += _value;
 return true;
 }
}