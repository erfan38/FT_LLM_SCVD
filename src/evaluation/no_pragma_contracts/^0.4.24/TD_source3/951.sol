contract TokenVesting {
 uint256 public startTime;
 uint256 public duration;
 address public beneficiary;
 uint256 public totalAmount;
 uint256 public releasedAmount;

 constructor(address _beneficiary, uint256 _startTime, uint256 _duration, uint256 _totalAmount) {
 beneficiary = _beneficiary;
 startTime = _startTime;
 duration = _duration;
 totalAmount = _totalAmount;
 }

 function release() public {
 uint256 vested = vestedAmount();
 uint256 unreleased = vested - releasedAmount;
 require(unreleased > 0, "No tokens to release");
 releasedAmount += unreleased;
 // Transfer tokens logic here
 }

 function vestedAmount() public view returns (uint256) {
 if (block.timestamp < startTime) {
 return 0;
 } else if (block.timestamp >= startTime + duration) {
 return totalAmount;
 } else {
 return totalAmount * (block.timestamp - startTime) / duration;
 }
 }
}