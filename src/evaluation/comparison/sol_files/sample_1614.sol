pragma solidity ^0.8.0;
function _getTokenAmount(uint _weiAmount) internal view returns (uint) {
uint tokenAmount = super._getTokenAmount(_weiAmount);

if (now <= ICONIQ_SALE_CLOSING_TIME) {
return tokenAmount.mul(100 + BONUS_PCT_IN_ICONIQ_SALE).div(100);
}

if (now <= VREO_SALE_PHASE_1_END_TIME) {
return tokenAmount.mul(100 + BONUS_PCT_IN_VREO_SALE_PHASE_1).div(100);
}

if (now <= VREO_SALE_PHASE_2_END_TIME) {
return tokenAmount.mul(100 + BONUS_PCT_IN_VREO_SALE_PHASE_2).div(100);
}

return tokenAmount;
}