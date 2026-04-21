pragma solidity ^0.8.0;
function ownerPausePayouts(bool newPayoutStatus) public
onlyOwner
{
payoutsPaused = newPayoutStatus;
}