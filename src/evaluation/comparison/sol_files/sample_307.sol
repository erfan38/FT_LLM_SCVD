pragma solidity ^0.8.0;
function ownerSetHouseEdge(uint newHouseEdge) public
onlyOwner
{
houseEdge = newHouseEdge;
}