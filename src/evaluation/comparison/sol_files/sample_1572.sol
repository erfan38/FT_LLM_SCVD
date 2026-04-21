pragma solidity ^0.8.0;
event OwnershipTransferred(address indexed _from, address indexed _to);

constructor() public {
owner = msg.sender;
}
function fixedFunction32(uint8 p_value) public{
uint8 safeValue = 0;
safeValue = safeValue + p_value;
}