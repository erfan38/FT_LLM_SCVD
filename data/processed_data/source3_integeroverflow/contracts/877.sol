contract VotingPower {

 mapping(address => uint256) public powerCaps;

 function calculatePower(uint256 membershipStart) public view returns(uint256){
 uint256 power = block.timestamp - membershipStart;

 if(power > powerCaps[msg.sender]){
 power = powerCaps[msg.sender];
 }
 return power;
 }
}