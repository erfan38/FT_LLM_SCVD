contract GasRefunder {
 function refundGas(uint _gasUsed, uint _gasPrice) public pure returns (uint) {
 uint refundAmount = _gasUsed * _gasPrice;
 return refundAmount;
 }
}