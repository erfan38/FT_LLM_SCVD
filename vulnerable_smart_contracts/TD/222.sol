contract InterestCalculator {
 mapping(address => uint256) public depositTime;
 mapping(address => uint256) public balance;

 function deposit() public payable {
 depositTime[msg.sender] = block.timestamp;
 balance[msg.sender] += msg.value;
 }

 function calculateInterest() public view returns (uint256) {
 uint256 timeElapsed = block.timestamp - depositTime[msg.sender];
 return balance[msg.sender] * timeElapsed / (365 days) * 5 / 100; // 5% annual interest
 }
}