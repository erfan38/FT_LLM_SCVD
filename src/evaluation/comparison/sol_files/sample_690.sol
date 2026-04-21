pragma solidity ^0.8.0;
function withdrawFunds(address payable _to, uint256 _amount)
public  returns (bool success);
function incrementBug20(uint8 incrementBugParam20) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam20;
}