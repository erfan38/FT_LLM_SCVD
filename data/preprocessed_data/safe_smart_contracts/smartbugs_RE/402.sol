contract NIZIGEN8 {
 mapping (address => uint) balances;
 mapping (address => uint) lastDepositTime;
 address public owner;
 uint public constant LOCK_TIME = 7 days;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 constructor() {
 owner = msg.sender;
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 lastDepositTime[msg.sender] = block.timestamp;
 }

 function withdraw(uint _amount) public {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 require(block.timestamp > lastDepositTime[msg.sender] + LOCK_TIME, "Funds are locked");
 balances[msg.sender] -= _amount;
 payable(msg.sender).transfer(_amount);
 }

 function transfer(uint _value, bytes memory _data) public onlyOwner returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }

 function getBalance(address _account) public view returns (uint) {
 return balances[_account];
 }

 function getLockTimeRemaining(address _account) public view returns (uint) {
 uint timePassed = block.timestamp - lastDepositTime[_account];
 if (timePassed >= LOCK_TIME) {
 return 0;
 }
 return LOCK_TIME - timePassed;
 }
}