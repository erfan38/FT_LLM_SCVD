contract TokenUnlock {

 mapping(address => uint256) public unlockLimits;

 function computeUnlock(uint256 lockTime) public view returns(uint256){
 uint256 unlocked = block.timestamp - lockTime;

 if(unlocked > unlockLimits[msg.sender]){
 unlocked = unlockLimits[msg.sender];
 }
 return unlocked;
 }
}