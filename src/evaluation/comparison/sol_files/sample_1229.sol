pragma solidity ^0.8.0;
function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
uint256 c = add(a,m);
uint256 d = sub(c,1);
return mul(div(d,m),m);
}