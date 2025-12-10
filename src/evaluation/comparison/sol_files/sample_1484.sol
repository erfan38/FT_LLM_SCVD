pragma solidity ^0.8.0;
bytes32 public paymentDetailsHash;

function decrementBug27() public{
uint8 underflowTest =0;
underflowTest = underflowTest -10;
}