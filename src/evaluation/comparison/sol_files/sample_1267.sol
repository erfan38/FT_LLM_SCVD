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


function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
if (contractStage == 1) {
remaining = contributionCaps[0].sub(this.balance);
} else {
remaining = 0;
}
return (contributionCaps[0],this.balance,remaining);
}