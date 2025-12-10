pragma solidity ^0.8.0;
function deleteChannel(string calldata channelId) external onlyMaster onlyWhenNotStopped
{
require(bytes(channelId).length > 0);

addressMap[channelId] = address(0);

emit DeleteAddress(channelId);
}