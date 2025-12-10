pragma solidity ^0.8.0;
modifier running() {
require(isRunning());
_;
}

function isRunning() public constant returns (bool) {
return (block.timestamp >= genesisTime && genesisTime > 0);
}