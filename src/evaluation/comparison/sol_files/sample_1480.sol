pragma solidity ^0.8.0;
uint256 public minSwapAmount;
function decrementBug11() public{
uint8 underflowTest =0;
underflowTest = underflowTest -10;
}