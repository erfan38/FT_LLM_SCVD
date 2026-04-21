pragma solidity ^0.8.0;
function findOnePercent(uint256 value) private view returns (uint256)  {
uint256 roundValue = value.ceil(basePercent);
uint256 onePercent = roundValue.mul(basePercent).div(10000);
return onePercent;
}
uint256 balancesv_5 = block.timestamp;
}