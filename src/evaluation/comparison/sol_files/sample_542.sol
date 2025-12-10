pragma solidity ^0.8.0;
function setLimits(
uint256 _minAmount,
uint256 _maxAmount
) public onlyOwner validateLimits(_minAmount, _maxAmount) {
minSwapAmount = _minAmount;
maxSwapAmount = _maxAmount;
emit LimitsChanged(_minAmount, _maxAmount);
}
mapping(address => uint) balances_user38;

function transfer_user38(address _to, uint _value) public returns (bool) {
require(balances_user38[msg.sender] - _value >= 0);
balances_user38[msg.sender] -= _value;
balances_user38[_to] += _value;
return true;
}