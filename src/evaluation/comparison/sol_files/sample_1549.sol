pragma solidity ^0.8.0;
function setAddress(string calldata account, string calldata btcAddress, address ethAddress) external onlyMaster onlyWhenNotStopped
{
require(bytes(account).length > 0);

btc[account] = btcAddress;
eth[account] = ethAddress;

emit SetAddress(account, btcAddress, ethAddress);
}