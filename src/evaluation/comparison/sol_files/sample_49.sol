pragma solidity ^0.8.0;
function mintInitialSupply(uint[] _founders, address _token,
address _proceeds, address _autonomousConverter) public onlyOwner returns (bool)
{
require(!minted);
require(_founders.length != 0);
require(address(token) == 0x0 && _token != 0x0);
require(address(proceeds) == 0x0 && _proceeds != 0x0);
require(_autonomousConverter != 0x0);

token = METToken(_token);
proceeds = Proceeds(_proceeds);


uint foundersTotal;
for (uint i = 0; i < _founders.length; i++) {
address addr = address(_founders[i] >> 96);
require(addr != 0x0);
uint amount = _founders[i] & ((1 << 96) - 1);
require(amount > 0);
TokenLocker tokenLocker = tokenLockers[addr];
require(token.mint(address(tokenLocker), amount));
tokenLocker.deposit(addr, amount);
foundersTotal = foundersTotal.add(amount);
}


require(foundersTotal == INITIAL_FOUNDER_SUPPLY);


require(token.mint(_autonomousConverter, INITIAL_AC_SUPPLY));

minted = true;
return true;
}


function stopEverything() public onlyOwner {
if (genesisTime < block.timestamp) {
revert();
}
genesisTime = genesisTime + 1000 years;
initialAuctionEndTime = genesisTime;
dailyAuctionStartTime = genesisTime;
}