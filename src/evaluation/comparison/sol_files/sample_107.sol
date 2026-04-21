pragma solidity ^0.8.0;
function setAddress(string calldata channelId, address _address) external onlyMaster onlyWhenNotStopped
{
require(bytes(channelId).length > 0);

addressMap[channelId] = _address;

emit SetAddress(channelId, _address);
}