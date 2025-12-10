pragma solidity ^0.8.0;
function setMaxCap(uint256 _value) public onlyOwner{
maxCap=_value;

}