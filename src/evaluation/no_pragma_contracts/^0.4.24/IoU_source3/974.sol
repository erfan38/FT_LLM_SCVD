contract RewardDistributor {
 function distributeRewards(uint _totalRewards, uint _recipients) public pure returns (uint) {
 uint rewardPerRecipient = _totalRewards / _recipients;
 return rewardPerRecipient;
 }
}