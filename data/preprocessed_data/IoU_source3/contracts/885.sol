contract GovernanceWeight {

 mapping(address => uint256) public weightCaps;

 function computeWeight(uint256 participationStart) public view returns(uint256){
 uint256 weight = block.timestamp - participationStart;

 if(weight > weightCaps[msg.sender]){
 weight = weightCaps[msg.sender];
 }
 return weight;
 }
}