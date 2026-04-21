pragma solidity ^0.8.0;
function rand() internal returns (uint256) {
seed = uint256(keccak256(seed, block.blockhash(block.number - 1), block.coinbase, block.difficulty));
return seed;
}