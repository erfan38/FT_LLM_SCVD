contract DailyAllowance {
 mapping(address => uint256) public lastWithdrawalTime;
 mapping(address => uint256) public dailyAllowance;

 function setAllowance(uint256 amount) public {
 dailyAllowance[msg.sender] = amount;
 }

 function withdraw() public {
 require(block.timestamp >= lastWithdrawalTime[msg.sender] + 1 days, "Can only withdraw once per day");
 lastWithdrawalTime[msg.sender] = block.timestamp;
 payable(msg.sender).transfer(dailyAllowance[msg.sender]);
 }
}