pragma solidity ^0.8.0;
function setMaxSend(uint256 _maxSend) onlyOwner external {
require(_maxSend > 0);
MAX_SEND = _maxSend;
}