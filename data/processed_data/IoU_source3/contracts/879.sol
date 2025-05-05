contract ReputationSystem {

 mapping(address => uint256) public repCaps;

 function calculateRep(uint256 joinDate) public view returns(uint256){
 uint256 reputation = block.timestamp - joinDate;

 if(reputation > repCaps[msg.sender]){
 reputation = repCaps[msg.sender];
 }
 return reputation;
 }
}