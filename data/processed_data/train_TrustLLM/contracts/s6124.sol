function addExtraReward(address _reward) external { require(msg.sender == rewardManager, "!authorized"); require(_reward != address(0), "!reward setting"); extraRewards.push(_reward); }
