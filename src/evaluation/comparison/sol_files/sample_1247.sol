pragma solidity ^0.8.0;
function isMaster() public view returns (bool)
{
return msg.sender == _master;
}