pragma solidity ^0.8.0;
function incrementBug8(uint8 incrementBugParam8) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam8;
}