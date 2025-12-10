contract LoyaltyPoints {
 uint public totalPoints = 500000;

 function earnPoints(uint points, uint validUntil) public returns (uint) {
 require(block.timestamp < validUntil);
 totalPoints = totalPoints + points;
 return totalPoints;
 }
}