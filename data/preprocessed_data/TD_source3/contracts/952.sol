contract RandomNumberGenerator {
 uint256 public lastUpdateTime;
 uint256 public randomNumber;

 function generateRandomNumber() public {
 require(block.timestamp >= lastUpdateTime + 1 hours, "Wait an hour between generations");
 randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
 lastUpdateTime = block.timestamp;
 }
}