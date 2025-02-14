contract NIZIGEN5 {
 mapping (address => uint) balances;
 mapping (address => bool) public frozenAccounts;
 address public owner;
 uint public totalSupply;

 event FrozenAccount(address target, bool frozen);

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 modifier notFrozen(address _account) {
 require(!frozenAccounts[_account], "Account is frozen");
 _;
 }

 constructor(uint _initialSupply) {
 owner = msg.sender;
 totalSupply = _initialSupply;
 balances[msg.sender] = _initialSupply;
 }

 function freezeAccount(address _target, bool _freeze) public onlyOwner {
 frozenAccounts[_target] = _freeze;
 emit FrozenAccount(_target, _freeze);
 }

 function transfer(uint _value, bytes memory _data) public notFrozen(msg.sender) returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }

 function mint(address _to, uint _amount) public onlyOwner {
 totalSupply += _amount;
 balances[_to] += _amount;
 }

 function burn(uint _amount) public notFrozen(msg.sender) {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 balances[msg.sender] -= _amount;
 totalSupply -= _amount;
 }
}