pragma solidity ^0.8.0;
function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
if (contractStage == 1) {
remaining = contributionCaps[0].sub(this.balance);
} else {
remaining = 0;
}
return (contributionCaps[0],this.balance,remaining);
}


function checkContributorBalance (address addr) view public returns (uint balance, uint cap, uint remaining) {
var c = whitelist[addr];
if (!c.authorized) {
cap = whitelistContract.checkMemberLevel(addr);
if (cap == 0) return (0,0,0);
} else {
cap = c.cap;
}
balance = c.balance;
if (contractStage == 1) {
if (cap<contributionCaps.length) {
if (nextCapTime == 0 || nextCapTime > block.timestamp) {
cap = contributionCaps[cap];
} else {
cap = nextContributionCaps[cap];
}
}
remaining = cap.sub(balance);
if (contributionCaps[0].sub(this.balance) < remaining) remaining = contributionCaps[0].sub(this.balance);
} else {
remaining = 0;
}
return (balance, cap, remaining);
}