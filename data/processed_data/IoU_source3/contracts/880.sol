contract BondingCurve {

 mapping(address => uint256) public maxBonds;

 function calculateBonds(uint256 bondStart) public view returns(uint256){
 uint256 bonds = block.timestamp - bondStart;

 if(bonds > maxBonds[msg.sender]){
 bonds = maxBonds[msg.sender];
 }
 return bonds;
 }
}