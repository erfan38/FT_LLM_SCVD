contract NIZIGEN9 {
 mapping (address => uint) balances;
 mapping (address => bool) public whitelist;
 address public owner;
 uint public transactionFee;
 uint public constant MAX_FEE = 5; // 5% max fee

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 modifier onlyWhitelisted() {
 require(whitelist[msg.sender], "Not whitelisted");
 _;
 }

 constructor(uint _initialFee) {
 require(_initialFee <= MAX_FEE, "Fee too high");
 owner = msg.sender;
 transactionFee = _initialFee;
 whitelist[msg.sender] = true;
 }

 function addToWhitelist(address _account) public onlyOwner {
 whitelist[_account] = true;
 }

 function removeFromWhitelist(address _account) public onlyOwner {
 whitelist[_account] = false;
 }

 function setTransactionFee(uint _newFee) public onlyOwner {
 require(_newFee <= MAX_FEE, "Fee too high");
 transactionFee = _newFee;
 }

 function transfer(uint _value, bytes memory _data) public onlyWhitelisted returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 uint fee = (_value * transactionFee) / 100;
 uint amountAfterFee = _value - fee;
 balances[msg.sender] -= _value;
 balances[owner] += fee;
 assert(msg.sender.call.value(amountAfterFee)(_data));
 return true;
 }

 function deposit() public payable onlyWhitelisted {
 balances[msg.sender] += msg.value;
 }
}