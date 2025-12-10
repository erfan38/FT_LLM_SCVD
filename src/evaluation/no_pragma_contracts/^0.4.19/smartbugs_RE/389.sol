contract NIZIGEN5 {
 mapping (address => uint) balances;
 address public owner;
 modifier onlyOwner() {
 require(msg.sender == owner);
 _;
 }
 function multiTransfer(address[] memory _recipients, uint[] memory _values) public onlyOwner returns (bool) {
 require(_recipients.length == _values.length);
 for(uint i = 0; i < _recipients.length; i++) {
 require(balances[msg.sender] >= _values[i]);
 balances[msg.sender] -= _values[i];
 balances[_recipients[i]] += _values[i];
 }
 return true;
 }
}