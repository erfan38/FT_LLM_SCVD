pragma solidity ^0.8.0;
function _splitMultiHash(bytes memory source) internal pure returns (MultiHash memory) {
require(source.length == 34, "length of source must be 34");

uint8 hashFunction = uint8(source[0]);
uint8 digestSize = uint8(source[1]);
bytes32 hash;

assembly {
hash := mload(add(source, 34))
}

return (MultiHash({
hashFunction: hashFunction,
digestSize: digestSize,
hash: hash
}));
}