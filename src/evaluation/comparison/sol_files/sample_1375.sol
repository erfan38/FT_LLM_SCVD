pragma solidity ^0.8.0;
function isExpired(uint _terminationDate) constant public returns (bool expired) {
return (block.timestamp > _terminationDate);
}