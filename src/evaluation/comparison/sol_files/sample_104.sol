pragma solidity ^0.8.0;
function isBlocked(address _account) internal returns (bool) {
if (blocked[_account] == 0)
return false;
Proposal p = proposals[blocked[_account]];
if (now > p.votingDeadline) {
blocked[_account] = 0;
return false;
} else {
return true;
}
}