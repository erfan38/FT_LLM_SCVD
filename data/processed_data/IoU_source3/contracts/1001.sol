contract RewardCalculator {
 uint256 public startTime;
 struct User {
 uint256 _points;
 }
 mapping(address => User) public userInfo;

 function calculateReward() internal view returns (uint256) {
 uint256 currentTime = block.timestamp;
 uint256 timeElapsed = currentTime - startTime;
 uint256 multiplier = timeElapsed / (7 days);
 return userInfo[msg.sender]._points * multiplier;
 }
}