pragma solidity ^0.8.0;
function () public payable running {
require(msg.value > 0);

uint amountForPurchase = msg.value;
uint excessAmount;

if (currentAuction() > whichAuction(lastPurchaseTick)) {
proceeds.closeAuction();
restartAuction();
}

if (isInitialAuctionEnded()) {
require(now >= dailyAuctionStartTime);
if (lastPurchaseAuction[msg.sender] < currentAuction()) {
if (amountForPurchase > DAILY_PURCHASE_LIMIT) {
excessAmount = amountForPurchase.sub(DAILY_PURCHASE_LIMIT);
amountForPurchase = DAILY_PURCHASE_LIMIT;
}
purchaseInTheAuction[msg.sender] = msg.value;
lastPurchaseAuction[msg.sender] = currentAuction();
} else {
require(purchaseInTheAuction[msg.sender] < DAILY_PURCHASE_LIMIT);
if (purchaseInTheAuction[msg.sender].add(amountForPurchase) > DAILY_PURCHASE_LIMIT) {
excessAmount = (purchaseInTheAuction[msg.sender].add(amountForPurchase)).sub(DAILY_PURCHASE_LIMIT);
amountForPurchase = amountForPurchase.sub(excessAmount);
}
purchaseInTheAuction[msg.sender] = purchaseInTheAuction[msg.sender].add(msg.value);
}
}

uint _currentTick = currentTick();

uint weiPerToken;
uint tokens;
uint refund;
(weiPerToken, tokens, refund) = calcPurchase(amountForPurchase, _currentTick);
require(tokens > 0);

if (now < initialAuctionEndTime && (token.totalSupply()).add(tokens) >= INITIAL_SUPPLY) {
initialAuctionEndTime = now;
dailyAuctionStartTime = ((initialAuctionEndTime / 1 days) + 1) * 1 days;
}

lastPurchaseTick = _currentTick;
lastPurchasePrice = weiPerToken;

assert(tokens <= mintable);
mintable = mintable.sub(tokens);

assert(refund <= amountForPurchase);
uint ethForProceeds = amountForPurchase.sub(refund);

proceeds.handleFund.value(ethForProceeds)();

require(token.mint(msg.sender, tokens));

refund = refund.add(excessAmount);
if (refund > 0) {
if (purchaseInTheAuction[msg.sender] > 0) {
purchaseInTheAuction[msg.sender] = purchaseInTheAuction[msg.sender].sub(refund);
}
msg.sender.transfer(refund);
}
emit LogAuctionFundsIn(msg.sender, ethForProceeds, tokens, lastPurchasePrice, refund);
}