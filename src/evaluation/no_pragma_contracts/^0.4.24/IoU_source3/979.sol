contract TokenVesting {
 function calculateVestedAmount(uint _totalTokens, uint _vestingPeriod, uint _timePassed) public pure returns (uint) {
 uint vestedAmount = (_totalTokens * _timePassed) / _vestingPeriod;
 return vestedAmount;
 }
}