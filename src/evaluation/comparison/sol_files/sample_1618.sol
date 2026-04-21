pragma solidity ^0.8.0;
function incrementBug35() public{
uint8 overflowTest =0;
overflowTest = overflowTest + 10;
}
443