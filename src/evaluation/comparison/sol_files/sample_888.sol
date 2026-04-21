pragma solidity ^0.8.0;
function setDistributor(address addr)
external
onlyOwner
{
require(addr != address(0));
distributor = addr;
}