pragma solidity ^0.8.0;
function changeTradeTracker(address _tradeTracker) onlyOwner {
tradeTracker = _tradeTracker;
}