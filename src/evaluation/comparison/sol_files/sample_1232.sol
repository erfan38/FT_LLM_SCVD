pragma solidity ^0.8.0;
function sqrt(uint x) internal pure returns (uint y) {
uint z = (x + 1) / 2;
y = x;
while (z < y) {
y = z;
z = (x / z + z) / 2;
}
}