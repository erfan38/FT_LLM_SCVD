contract PointSystem {
 uint public totalPoints = 100;

 function awardPoints(uint points, uint expiry) public returns (uint) {
 require(block.timestamp < expiry);
 totalPoints = totalPoints + points;
 return totalPoints;
 }
}