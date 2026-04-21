pragma solidity ^0.8.0;
address payable public swapsContract;
function incrementBug12(uint8 incrementBugParam12) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam12;
}