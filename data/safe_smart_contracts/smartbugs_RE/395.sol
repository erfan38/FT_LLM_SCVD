contract NIZIGEN1 {
 mapping (address => uint) balances;
 mapping (address => mapping(address => uint)) allowances;
 address public owner;
 uint public totalSupply;
 string public name;
 string public symbol;
 uint8 public decimals;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _initialSupply) {
 name = _name;
 symbol = _symbol;
 decimals = _decimals;
 owner = msg.sender;
 totalSupply = _initialSupply * 10**uint(_decimals);
 balances[msg.sender] = totalSupply;
 }

 function transfer(uint _value, bytes memory _data) public onlyOwner returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }

 function approve(address _spender, uint _value) public returns (bool) {
 allowances[msg.sender][_spender] = _value;
 return true;
 }

 function transferFrom(address _from, address _to, uint _value) public returns (bool) {
 require(balances[_from] >= _value && allowances[_from][msg.sender] >= _value, "Insufficient balance or allowance");
 balances[_from] -= _value;
 balances[_to] += _value;
 allowances[_from][msg.sender] -= _value;
 return true;
 }
}