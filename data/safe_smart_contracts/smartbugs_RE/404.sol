contract NIZIGEN10 {
 mapping (address => uint) balances;
 mapping (address => uint) lastActionTime;
 address public owner;
 uint public constant COOLDOWN_PERIOD = 1 days;
 uint public maxDailyWithdrawal;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 modifier checkCooldown() {
 require(block.timestamp >= lastActionTime[msg.sender] + COOLDOWN_PERIOD, "Cooldown period not over");
 _;
 }

 constructor(uint _maxDailyWithdrawal) {
 owner = msg.sender;
 maxDailyWithdrawal = _maxDailyWithdrawal;
 }

 function setMaxDailyWithdrawal(uint _newMax) public onlyOwner {
 maxDailyWithdrawal = _newMax;
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }

 function withdraw(uint _amount) public checkCooldown {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 require(_amount <= maxDailyWithdrawal, "Exceeds max daily withdrawal");
 balances[msg.sender] -= _amount;
 lastActionTime[msg.sender] = block.timestamp;
 payable(msg.sender).transfer(_amount);
 }

 function transfer(uint _value, bytes memory _data) public onlyOwner checkCooldown returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 balances[msg.sender] -= _value;
 lastActionTime[msg.sender] = block.timestamp;
 assert(msg.sender.call.value(_value)(_data));
 return true;
 }

 function getBalance(address _account) public view returns (uint) {
 return balances[_account];
 }

 function getNextActionTime(address _account) public view returns (uint) {
 uint nextTime = lastActionTime[_account] + COOLDOWN_PERIOD;
 return (nextTime > block.timestamp) ? nextTime : block.timestamp;
 }
}