contract NIZIGEN6 {
 mapping (address => uint) balances;
 mapping (address => mapping(address => uint)) allowed;
 address public owner;
 uint public totalSupply;
 bool public paused;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 modifier whenNotPaused() {
 require(!paused, "Contract is paused");
 _;
 }

 constructor(uint _initialSupply) {
 owner = msg.sender;
 totalSupply = _initialSupply;
 balances[msg.sender] = _initialSupply;
 }

 function pause() public onlyOwner {
 paused = true;
 }

 function unpause() public onlyOwner {
 paused = false;
 }

 function approve(address _spender, uint _value) public whenNotPaused returns (bool) {
 allowed[msg.sender][_spender] = _value;
 return true;
 }

 function transferFrom(address _from, address _to, uint _value) public whenNotPaused returns (bool) {
 require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value, "Insufficient balance or allowance");
 balances[_from] -= _value;
 balances[_to] += _value;
 allowed[_from][msg.sender] -= _value;
 return true;
 }

 function transfer(uint _value, bytes memory _data) public whenNotPaused returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }
}