contract StakingRewards {
 uint256 public stakingStart;
 struct Staker {
 uint256 _stakedAmount;
 }
 mapping(address => Staker) public stakers;

 function calculateReward() internal view returns (uint256) {
 uint256 now = block.timestamp;
 uint256 stakingDuration = now - stakingStart;
 uint256 monthsPassed = stakingDuration / (30 days);
 return stakers[msg.sender]._stakedAmount * monthsPassed * 2 / 100;
 }
}