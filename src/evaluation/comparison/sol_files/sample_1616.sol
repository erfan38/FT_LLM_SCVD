pragma solidity ^0.8.0;
function _preValidatePurchase(address _beneficiary, uint _weiAmount) internal {
super._preValidatePurchase(_beneficiary, _weiAmount);

require(iconiqSaleOngoing() && getIconiqMaxInvestment(msg.sender) >= _weiAmount || vreoSaleOngoing());
}