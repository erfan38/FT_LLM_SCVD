contract NIZIGEN7 {
 mapping (address => uint) balances;
 address public owner;
 uint public lastActivityTime;
 uint public constant ACTIVITY_TIMEOUT = 365 days;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 modifier updateActivity() {
 lastActivityTime = block.timestamp;
 _;
 }

 constructor() {
 owner = msg.sender;
 lastActivityTime = block.timestamp;
 }

 function transferOwnership(address newOwner) public onlyOwner {
 require(newOwner != address(0), "Invalid new owner");
 owner = newOwner;
 }

 function deposit() public payable updateActivity {
 balances[msg.sender] += msg.value;
 }

 function withdraw(uint _amount) public onlyOwner updateActivity {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 balances[msg.sender] -= _amount;
 payable(msg.sender).transfer(_amount);
 }

 function transfer(uint _value, bytes memory _data) public onlyOwner updateActivity returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }

 function recoverInactiveTokens() public {
 require(block.timestamp > lastActivityTime + ACTIVITY_TIMEOUT, "Contract is still active");
 selfdestruct(payable(owner));
 }
}