pragma solidity ^0.8.0;
function updateAccount(string calldata from, string calldata to) external onlyMaster onlyWhenNotStopped
{
require(bytes(from).length > 0);
require(bytes(to).length > 0);

btc[to] = btc[from];
eth[to] = eth[from];

btc[from] = '';
eth[from] = address(0);

emit UpdateAddress(from, to);
}