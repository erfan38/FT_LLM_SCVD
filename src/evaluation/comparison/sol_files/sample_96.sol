pragma solidity ^0.8.0;
}



contract MultiHashWrapper {

struct MultiHash {
bytes32 hash;
uint8 hashFunction;
uint8 digestSize;
}

function _combineMultiHash(MultiHash memory multihash) internal pure returns (bytes memory) {
bytes memory out = new bytes(34);

out[0] = byte(multihash.hashFunction);
out[1] = byte(multihash.digestSize);

uint8 i;
for (i = 0; i < 32; i++) {
out[i+2] = multihash.hash[i];
}

return out;
}