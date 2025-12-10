pragma solidity ^0.8.0;
function getTotalBalance() public view returns (uint256 tokensCurrentlyInVault) {

return token.balanceOf(address(this));

}