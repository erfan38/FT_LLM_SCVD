contract AirDropEligibility {

 mapping(address => uint256) public maxEligibility;

 function calculateEligibility(uint256 registrationTime) public view returns(uint256){
 uint256 eligibility = block.timestamp - registrationTime;

 if(eligibility > maxEligibility[msg.sender]){
 eligibility = maxEligibility[msg.sender];
 }
 return eligibility;
 }
}