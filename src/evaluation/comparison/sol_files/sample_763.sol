pragma solidity ^0.8.0;
function toKey(address _addr, uint _release) internal pure returns (bytes32 result) {
result = 0x5749534800000000000000000000000000000000000000000000000000000000;
assembly {
result := or(result, mul(_addr, 0x10000000000000000))
result := or(result, _release)
}
}