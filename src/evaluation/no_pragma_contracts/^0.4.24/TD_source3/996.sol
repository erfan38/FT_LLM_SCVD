contract TimedInvestment {
 mapping(address => uint256) public investments;
 mapping(address => uint256) public investmentTimes;

 function invest() public payable {
 investments[msg.sender] += msg.value;
 investmentTimes[msg.sender] = block.timestamp;
 }

 function withdrawWithInterest() public {
 uint256 timePassed = block.timestamp - investmentTimes[msg.sender];
 uint256 interest = (investments[msg.sender] * timePassed * 5) / (100 * 365 days);
 uint256 totalAmount = investments[msg.sender] + interest;
 investments[msg.sender] = 0;
 payable(msg.sender).transfer(totalAmount);
 }
}