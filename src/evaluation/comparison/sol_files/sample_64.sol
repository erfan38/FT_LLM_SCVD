pragma solidity ^0.8.0;
function totalBspAmount() public view returns (uint256) {
return BSPToken.balanceOf(this).add(minted);
}