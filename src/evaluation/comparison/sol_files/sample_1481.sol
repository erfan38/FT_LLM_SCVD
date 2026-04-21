pragma solidity ^0.8.0;
function buyTokens(address _beneficiary) public payable {

uint256 weiAmount = msg.value;
require(_beneficiary != address(0));
require(weiAmount != 0);
bool isPresale = block.timestamp >= PRESALE_OPENING_TIME && block.timestamp <= PRESALE_CLOSING_TIME;
bool isCrowdsale = block.timestamp >= CROWDSALE_OPENING_TIME && block.timestamp <= CROWDSALE_CLOSING_TIME;
require(isPresale || isCrowdsale);
uint256 tokens;

if (isCrowdsale) {
require(crowdsaleWeiRaised.add(weiAmount) <= CROWDSALE_WEI_CAP);
require(crowdsaleContributions[_beneficiary].add(weiAmount) <= getCrowdsaleUserCap());


tokens = _getCrowdsaleTokenAmount(weiAmount);
require(tokens != 0);


crowdsaleWeiRaised = crowdsaleWeiRaised.add(weiAmount);
} else if (isPresale) {
require(presaleWeiRaised.add(weiAmount) <= PRESALE_WEI_CAP);
require(whitelist[_beneficiary]);


tokens = weiAmount.mul(PRESALE_RATE).div(1 ether);
require(tokens != 0);


presaleWeiRaised = presaleWeiRaised.add(weiAmount);
}

_processPurchase(_beneficiary, tokens);
emit TokenPurchase(
msg.sender,
_beneficiary,
weiAmount,
tokens
);

if (isCrowdsale) crowdsaleContributions[_beneficiary] = crowdsaleContributions[_beneficiary].add(weiAmount);
deposited[_beneficiary] = deposited[_beneficiary].add(msg.value);
}