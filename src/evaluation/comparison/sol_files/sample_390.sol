pragma solidity ^0.8.0;
event ReceivedFunds(address _from, uint256 _amount);
function decrementBug31() public{
uint8 underflowTest =0;
underflowTest = underflowTest -10;
}