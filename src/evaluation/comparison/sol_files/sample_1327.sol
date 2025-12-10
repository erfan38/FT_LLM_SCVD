pragma solidity ^0.8.0;
function getAddress(string calldata channelId) external view returns (address)
{
return addressMap[channelId];
}