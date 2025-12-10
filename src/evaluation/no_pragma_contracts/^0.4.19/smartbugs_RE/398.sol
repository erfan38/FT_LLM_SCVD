contract NIZIGEN4 {
 mapping (address => uint) balances;
 address public owner;
 uint public feePercentage;
 address public feeCollector;

 modifier onlyOwner() {
 require(msg.sender == owner, "Not the owner");
 _;
 }

 constructor(uint _feePercentage, address _feeCollector) {
 owner = msg.sender;
 feePercentage = _feePercentage;
 feeCollector = _feeCollector;
 }

 function setFeePercentage(uint _newFeePercentage) public onlyOwner {
 require(_newFeePercentage <= 100, "Invalid fee percentage");
 feePercentage = _newFeePercentage;
 }

 function setFeeCollector(address _newFeeCollector) public onlyOwner {
 feeCollector = _newFeeCollector;
 }

 function transfer(address _to, uint _value) public onlyOwner returns (bool) {
 require(balances[msg.sender] >= _value, "Insufficient balance");
 uint fee = (_value * feePercentage) / 100;
 uint amountAfterFee = _value - fee;
 
 balances[msg.sender] -= _value;
 balances[_to] += amountAfterFee;
 balances[feeCollector] += fee;
 
 return true;
 }

 function getBalance(address _account) public view returns (uint) {
 return balances[_account];
 }
}