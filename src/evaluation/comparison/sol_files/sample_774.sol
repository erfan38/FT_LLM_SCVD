pragma solidity ^0.8.0;
modifier canTransfer(address _from) {
if (transferWhitelist[_from] == false) {
require(block.timestamp >= releaseTime);
require(fundingLowcapReached == true);
}
_;
}

function transfer(address _to, uint256 _aces)
public
isInitialized
canTransfer(msg.sender)
tokensAreUnlocked(msg.sender, _aces)
returns (bool) {
markReleased();
return super.transfer(_to, _aces);
}