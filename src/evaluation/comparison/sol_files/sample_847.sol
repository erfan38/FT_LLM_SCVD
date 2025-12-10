pragma solidity ^0.8.0;
function mintableAmount() public view returns (uint256) {

if(started == false || startTime >= block.timestamp){
return 0;
}

if (block.timestamp >= startTime.add(duration)){
return BSPToken.balanceOf(this);
}

uint currentYear = block.timestamp.sub(startTime).div(1 years);
uint currentDay = (block.timestamp.sub(startTime) % (1 years)).div(1 days);
uint currentMintable = 0;

for (uint i = 0; i < currentYear; i++){
currentMintable = currentMintable.add(rewardAmount.mul(miningRate[i]).div(100));
}
currentMintable = currentMintable.add(rewardAmount.mul(miningRate[currentYear]).div(36500).mul(currentDay));

return currentMintable.sub(minted);
}