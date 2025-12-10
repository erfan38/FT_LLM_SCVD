contract NIZIGEN2 {
 mapping (address => uint) balances;
 address public owner;
 uint public withdrawalLimit;
 uint public lastWithdrawalTime;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 constructor(uint _withdrawalLimit) {
 owner = msg.sender;
 withdrawalLimit = _withdrawalLimit;
 lastWithdrawalTime = block.timestamp;
 }

 function deposit() public payable {
 balances[msg.sender] += msg.value;
 }

 function withdraw(uint _amount) public onlyOwner {
 require(balances[msg.sender] >= _amount, "Insufficient balance");
 require(_amount <= withdrawalLimit, "Exceeds withdrawal limit");
 require(block.timestamp >= lastWithdrawalTime + 1 days, "Too soon since last withdrawal");

 balances[msg.sender] -= _amount;
 lastWithdrawalTime = block.timestamp;
 payable(msg.sender).transfer(_amount);
 }

 function setWithdrawalLimit(uint _newLimit) public onlyOwner {
 withdrawalLimit = _newLimit;
 }
}