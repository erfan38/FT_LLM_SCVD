pragma solidity ^0.8.0;
function deleteAccount(string calldata account) external onlyMaster onlyWhenNotStopped
{
require(bytes(account).length > 0);

btc[account] = '';
eth[account] = address(0);

emit DeleteAddress(account);
}