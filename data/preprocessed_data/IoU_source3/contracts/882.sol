contract StakeUnlock {

 mapping(address => uint256) public unlockCaps;

 function calculateUnlock(uint256 stakeTime) public view returns(uint256){
 uint256 unlocked = block.timestamp - stakeTime;

 if(unlocked > unlockCaps[msg.sender]){
 unlocked = unlockCaps[msg.sender];
 }
 return unlocked;
 }
}