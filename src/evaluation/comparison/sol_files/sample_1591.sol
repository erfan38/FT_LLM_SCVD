pragma solidity ^0.8.0;
function isComplete() public view returns (bool) {
return address(this).balance < 1 ether;
}