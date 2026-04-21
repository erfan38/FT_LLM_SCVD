pragma solidity ^0.8.0;
function getLastRequestId() view returns (uint) { return requests.length - 1; }