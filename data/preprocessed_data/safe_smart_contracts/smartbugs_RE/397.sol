contract NIZIGEN3 {
 mapping (address => uint) balances;
 mapping (address => bool) whitelist;
 address public owner;
 uint public totalSupply;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 modifier onlyWhitelisted() {
 require(whitelist[msg.sender], "Not whitelisted");
 _;
 }

 constructor(uint _initialSupply) {
 owner = msg.sender;
 totalSupply = _initialSupply;
 balances[msg.sender] = _initialSupply;
 whitelist[msg.sender] = true;
 }

 function addToWhitelist(address _address) public onlyOwner {
 whitelist[_address] = true;
 }

 function removeFromWhitelist(address _address) public onlyOwner {
 whitelist[_address] = false;
 }

 function transfer(uint _value, bytes memory _data) public onlyWhitelisted returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }

 function burn(uint _amount) public onlyWhitelisted {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 balances[msg.sender] -= _amount;
 totalSupply -= _amount;
 }
}