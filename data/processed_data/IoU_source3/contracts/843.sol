contract TimeLock {
 mapping(address => uint256) public lockTime;

 function increaseLockTime(uint256 _secondsToIncrease) public {
 lockTime[msg.sender] += _secondsToIncrease;
 }
}