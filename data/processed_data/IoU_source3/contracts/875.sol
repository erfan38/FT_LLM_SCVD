contract LoyaltyProgram {

 mapping(address => uint256) public pointLimits;

 function calculatePoints(uint256 registrationTime) public view returns(uint256){
 uint256 points = block.timestamp - registrationTime;

 if(points > pointLimits[msg.sender]){
 points = pointLimits[msg.sender];
 }
 return points;
 }
}