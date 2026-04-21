pragma solidity ^0.8.0;
function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
notContract()
internal
returns(uint256) {

uint256 purchaseEthereum = _incomingEthereum;
uint256 excess;
if(purchaseEthereum > 5 ether) {
if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 100 ether) {
purchaseEthereum = 5 ether;
excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
}
}

purchaseTokens(purchaseEthereum, _referredBy);

if (excess > 0) {
msg.sender.transfer(excess);
}
}