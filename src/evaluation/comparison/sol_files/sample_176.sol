pragma solidity ^0.8.0;
function incrementBug32(uint8 incrementBugParam32) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam32;
}