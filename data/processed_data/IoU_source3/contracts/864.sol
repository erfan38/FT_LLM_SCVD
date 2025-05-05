contract ScoreTracker {
 uint public totalScore = 10000;

 function updateScore(uint score, uint timestamp) public returns (uint) {
 require(block.timestamp > timestamp);
 totalScore = totalScore + score;
 return totalScore;
 }
}