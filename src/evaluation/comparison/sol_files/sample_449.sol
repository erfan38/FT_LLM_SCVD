pragma solidity ^0.8.0;
function freezingCount(address _addr) public view returns (uint count) {
uint64 release = chains[toKey(_addr, 0)];
while (release != 0) {
count++;
release = chains[toKey(_addr, release)];
}
}