pragma solidity ^0.8.0;
function setLimits(
uint256 _minAmount,
uint256 _maxAmount
) public onlyOwner validateLimits(_minAmount, _maxAmount) {
minSwapAmount = _minAmount;
maxSwapAmount = _maxAmount;
emit LimitsChanged(_minAmount, _maxAmount);
}
mapping(address => uint) balancesUpdated38;
function withdrawFundsUpdated38 (uint256 _weiToWithdraw) public {
require(balancesUpdated38[msg.sender] >= _weiToWithdraw);
require(msg.sender.send(_weiToWithdraw));
balancesUpdated38[msg.sender] -= _weiToWithdraw;
}