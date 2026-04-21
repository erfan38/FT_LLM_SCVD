pragma solidity ^0.8.0;
address public owner;

function incrementBug40(uint8 incrementBugParam40) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam40;
}