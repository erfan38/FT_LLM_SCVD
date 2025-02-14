contract StakingPeriod {
 uint256 public stakingBegin;
 uint256 public stakingFinish;
 uint256 public stakingLength;

 function initiateStaking() external returns (uint256) {
 stakingBegin = block.timestamp;
 stakingFinish = stakingBegin + stakingLength;
 return stakingFinish;
 }
}