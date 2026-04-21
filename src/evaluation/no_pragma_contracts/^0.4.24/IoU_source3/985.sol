contract TimeLock {
 mapping(address => uint) public balances;
 mapping(address => uint) public lockTime;

 function increaseLockTime(uint _secondsToIncrease) public {
 lockTime[msg.sender] += _secondsToIncrease;
 }
}