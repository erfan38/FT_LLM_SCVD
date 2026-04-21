contract GameRound {
 uint256 public roundStart;
 uint256 public roundDuration;

 constructor(uint256 _duration) {
 roundStart = block.number;
 roundDuration = _duration;
 }

 function isRoundActive() public view returns (bool) {
 return block.number < roundStart + roundDuration;
 }

 function startNewRound() public {
 require(block.number >= roundStart + roundDuration, "Current round not finished");
 roundStart = block.number;
 }
}