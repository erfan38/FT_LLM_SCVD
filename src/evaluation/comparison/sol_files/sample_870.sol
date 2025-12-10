pragma solidity ^0.8.0;
function availableTradingFeeOwner() public view returns(uint256){
return tokens[address(0)][feeAccount];
}