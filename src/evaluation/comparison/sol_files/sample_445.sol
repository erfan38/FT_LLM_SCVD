pragma solidity ^0.8.0;
function decrementBug7() public{
uint8 underflowTest =0;
underflowTest = underflowTest -10;
}