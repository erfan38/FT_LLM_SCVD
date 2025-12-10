pragma solidity ^0.8.0;
function mint() public whenStarted {
uint256 unminted = mintableAmount();
require(unminted > 0);

minted = minted.add(unminted);
BSPToken.safeTransfer(distributor, unminted);

emit Mint(unminted);
}