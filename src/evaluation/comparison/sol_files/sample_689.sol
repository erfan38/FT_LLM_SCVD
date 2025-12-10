pragma solidity ^0.8.0;
bool public isCrowdsaleFinalized = false;
mapping (address => uint256) public deposited;


event CrowdsaleFinalized();
event RefundsEnabled();
event Refunded(address indexed beneficiary, uint256 weiAmount);


function finalizeCrowdsale() external {
require(!isCrowdsaleFinalized);
require(block.timestamp > CROWDSALE_CLOSING_TIME || (block.timestamp > PRESALE_CLOSING_TIME && presaleWeiRaised < PRESALE_WEI_GOAL));

if (combinedGoalReached()) {
wallet.transfer(address(this).balance);
} else {
emit RefundsEnabled();
}

emit CrowdsaleFinalized();
isCrowdsaleFinalized = true;
}