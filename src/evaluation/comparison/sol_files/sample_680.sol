pragma solidity ^0.8.0;
function availableFunds() public view returns(uint256) {
return address(this).balance;
}