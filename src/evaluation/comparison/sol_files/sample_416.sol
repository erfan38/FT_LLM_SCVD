pragma solidity ^0.8.0;
address private _factory;


modifier initializeTemplate() {
_factory = msg.sender;

uint32 codeSize;
assembly { codeSize := extcodesize(address) }
require(codeSize == 0, "must be called within contract constructor");
_;
}


function getCreator() public view returns (address creator) {
creator = iFactory(_factory).getInstanceCreator(address(this));
}