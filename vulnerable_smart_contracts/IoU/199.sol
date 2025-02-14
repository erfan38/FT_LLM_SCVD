contract BlockReward {
 function calculateBlockReward(uint _baseReward, uint _blockNumber) public pure returns (uint) {
 uint reward = _baseReward + (_blockNumber * 100);
 return reward;
 }
}