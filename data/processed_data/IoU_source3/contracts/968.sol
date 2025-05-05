contract RewardMultiplier {
 function calculateReward(uint _baseReward, uint _multiplier) public pure returns (uint) {
 uint totalReward = _baseReward * _multiplier;
 return totalReward;
 }
}