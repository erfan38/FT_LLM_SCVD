pragma solidity ^0.8.0;
function getAddress(string calldata account) external view returns (string memory, address)
{
return (btc[account], eth[account]);
}