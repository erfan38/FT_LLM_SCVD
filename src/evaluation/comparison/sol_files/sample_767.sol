pragma solidity ^0.8.0;
function updateChannel(string calldata from, string calldata to, address _address) external onlyMaster onlyWhenNotStopped
{
require(bytes(from).length > 0);
require(bytes(to).length > 0);
require(addressMap[to] == address(0));

addressMap[to] = _address;

addressMap[from] = address(0);

emit UpdateAddress(from, to);
}