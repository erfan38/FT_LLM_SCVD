pragma solidity ^0.8.0;
modifier onlyOwner {
require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
_;
}

function getBalance() external view returns(uint){
return address(this).balance;
}