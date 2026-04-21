pragma solidity ^0.8.0;
function getState() public constant returns (State) {
if(finalized) return State.Finalized;
else if (address(finalizeAgent) == 0) return State.Preparing;
else if (!finalizeAgent.isSane()) return State.Preparing;
else if (!pricingStrategy.isSane(address(this))) return State.Preparing;
else if (block.timestamp < startsAt) return State.PreFunding;
else if (block.timestamp <= endsAt && !isCrowdsaleFull()) return State.Funding;
else if (isMinimumGoalReached()) return State.Success;
else if (!isMinimumGoalReached() && weiRaised > 0 && loadedRefund >= weiRaised) return State.Refunding;
else return State.Failure;
}