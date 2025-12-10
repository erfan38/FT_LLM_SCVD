pragma solidity ^0.8.0;
function convert(WhichToken whichFrom, uint _minReturn, uint amnt) internal returns (uint) {
WhichToken to = WhichToken.Met;
if (whichFrom == WhichToken.Met) {
to = WhichToken.Eth;
require(reserveToken.transferFrom(msg.sender, this, amnt));
}

uint mintRet = mint(whichFrom, amnt, 1);

return redeem(to, mintRet, _minReturn);
}