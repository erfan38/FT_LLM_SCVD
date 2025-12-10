pragma solidity ^0.8.0;
contract Counter {
uint8 public count;

function increment() external {
count = count + 1;
}
}