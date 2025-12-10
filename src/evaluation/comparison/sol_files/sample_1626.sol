pragma solidity ^0.8.0;
function ComputePlantBoostFactor() public view returns(uint256) {


uint256 _timeLapsed = now.sub(lastRootPlant);


uint256 _boostFactor = (_timeLapsed.mul(1)).add(100);
return _boostFactor;
}