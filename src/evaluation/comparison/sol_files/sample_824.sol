pragma solidity ^0.8.0;
function balanceOf(address tokenOwner) public view returns (uint balance) {
return balances[tokenOwner];
}