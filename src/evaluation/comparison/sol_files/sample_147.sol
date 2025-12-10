pragma solidity ^0.8.0;
function balanceOf(WhichToken which) internal view returns (uint) {
if (which == WhichToken.Eth) return address(this).balance;
if (which == WhichToken.Met) return reserveToken.balanceOf(this);
revert();
}