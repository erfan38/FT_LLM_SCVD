contract NIZIGEN4 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function transfer(address _to, uint _value) public onlyOwner returns (bool) {
 require(balances[msg.sender] >= _value);
 balances[msg.sender] -= _value;
 balances[_to] += _value;
 return true;
 }
}