pragma solidity ^0.8.0;
function skipInitBecauseIAmNotOg(address _token, address _proceeds, uint _genesisTime,
uint _minimumPrice, uint _startingPrice, uint _timeScale, bytes8 _chain,
uint _initialAuctionEndTime) public onlyOwner returns (bool) {
require(!minted);
require(!initialized);
require(_timeScale != 0);
require(address(token) == 0x0 && _token != 0x0);
require(address(proceeds) == 0x0 && _proceeds != 0x0);
initPricer();


token = METToken(_token);
proceeds = Proceeds(_proceeds);

INITIAL_FOUNDER_SUPPLY = 0;
INITIAL_AC_SUPPLY = 0;
mintable = 0;


genesisTime = _genesisTime;
initialAuctionEndTime = _initialAuctionEndTime;



if (initialAuctionEndTime == (initialAuctionEndTime / 1 days) * 1 days) {
dailyAuctionStartTime = initialAuctionEndTime;
} else {
dailyAuctionStartTime = ((initialAuctionEndTime / 1 days) + 1) * 1 days;
}

lastPurchaseTick = 0;

if (_minimumPrice > 0) {
minimumPrice = _minimumPrice;
}

timeScale = _timeScale;

if (_startingPrice > 0) {
lastPurchasePrice = _startingPrice * 1 ether;
} else {
lastPurchasePrice = 2 ether;
}
chain = _chain;
minted = true;
initialized = true;
return true;
}






function initAuctions(uint _startTime, uint _minimumPrice, uint _startingPrice, uint _timeScale)
public onlyOwner returns (bool)
{
require(minted);
require(!initialized);
require(_timeScale != 0);
initPricer();
if (_startTime > 0) {
genesisTime = (_startTime / (1 minutes)) * (1 minutes) + 60;
} else {
genesisTime = block.timestamp + 60 - (block.timestamp % 60);
}

initialAuctionEndTime = genesisTime + initialAuctionDuration;



if (initialAuctionEndTime == (initialAuctionEndTime / 1 days) * 1 days) {
dailyAuctionStartTime = initialAuctionEndTime;
} else {
dailyAuctionStartTime = ((initialAuctionEndTime / 1 days) + 1) * 1 days;
}

lastPurchaseTick = 0;

if (_minimumPrice > 0) {
minimumPrice = _minimumPrice;
}

timeScale = _timeScale;

if (_startingPrice > 0) {
lastPurchasePrice = _startingPrice * 1 ether;
} else {
lastPurchasePrice = 2 ether;
}

for (uint i = 0; i < founders.length; i++) {
TokenLocker tokenLocker = tokenLockers[founders[i]];
tokenLocker.lockTokenLocker();
}

initialized = true;
return true;
}