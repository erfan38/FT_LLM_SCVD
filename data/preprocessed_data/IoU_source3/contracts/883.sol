contract TokenVesting {

 mapping(address => uint256) public vestingLimits;

 function computeVestedTokens(uint256 vestingStart) public view returns(uint256){
 uint256 vested = block.timestamp - vestingStart;

 if(vested > vestingLimits[msg.sender]){
 vested = vestingLimits[msg.sender];
 }
 return vested;
 }
}