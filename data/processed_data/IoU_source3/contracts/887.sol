contract StakingPower {

 mapping(address => uint256) public powerLimits;

 function computePower(uint256 stakeTime) public view returns(uint256){
 uint256 power = block.timestamp - stakeTime;

 if(power > powerLimits[msg.sender]){
 power = powerLimits[msg.sender];
 }
 return power;
 }
}