pragma solidity ^0.8.0;
function combinedGoalReached() public view returns (bool) {
return presaleWeiRaised.add(crowdsaleWeiRaised) >= COMBINED_WEI_GOAL;
}

}