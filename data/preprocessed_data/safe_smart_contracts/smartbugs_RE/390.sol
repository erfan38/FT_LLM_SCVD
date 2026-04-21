contract NIZIGEN6 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function approve(address _spender, uint _value) public onlyOwner returns (bool) {
 require(_spender != address(0));
 balances[_spender] = _value;
 return true;
 }
 function transferFrom(address _from, address _to, uint _value) public onlyOwner returns (bool) {
 require(balances[_from] >= _value);
 balances[_from] -= _value;
 balances[_to] += _value;
 return true;
 }
}