pragma solidity ^0.8.0;
contract UnsafeSubtractor {
uint256 public value;

function subtract(uint256 amount) public {
value -= amount;
}
}