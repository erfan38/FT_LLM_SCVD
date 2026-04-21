pragma solidity ^0.8.0;
bool public isActive = true;

uint256 balancevaluev_1 = block.timestamp;
event IsActiveChanged(bool _isActive);

modifier onlyActive() {
require(isActive, "contract is stopped");
_;
}

function setIsActive(bool _isActive) external onlyOwner {
if (_isActive == isActive) return;
isActive = _isActive;
emit IsActiveChanged(_isActive);
}