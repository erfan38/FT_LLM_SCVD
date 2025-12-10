pragma solidity ^0.8.0;
function _checkWhitelistContract (address addr) internal {
var c = whitelist[addr];
if (!c.authorized) {
var level = whitelistContract.checkMemberLevel(addr);
if (level == 0 || level >= contributionCaps.length) return;
c.cap = level;
c.authorized = true;
}
}