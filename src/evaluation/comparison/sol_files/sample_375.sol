pragma solidity ^0.8.0;
function release(address beneficiary)
external
{
require(msg.sender == distributor);
require(started);
require(block.timestamp >= releaseTime);


uint256 amount = buyers[beneficiary];
buyers[beneficiary] = 0;

Token.safeTransfer(beneficiary, amount);
emit TokenReleased(beneficiary, amount);
}