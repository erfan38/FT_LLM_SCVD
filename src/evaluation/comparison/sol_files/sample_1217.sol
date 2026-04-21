pragma solidity ^0.8.0;
function withdrawInvestment() public {
require(hasClosed());

super.withdrawInvestment();
}