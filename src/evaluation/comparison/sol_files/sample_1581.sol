pragma solidity ^0.8.0;
function checkCandy(address recipient) constant returns (uint256 remaining) {
if(candyBook[recipient]) return 0;
else return candyPrice;
}