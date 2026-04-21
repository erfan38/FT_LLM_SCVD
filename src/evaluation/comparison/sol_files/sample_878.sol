pragma solidity ^0.8.0;
function buyTokens(address beneficiary) payable
{
require(
block.timestamp < deadline
&& tokenPrice > 0
&& YellowBetterToken(tokenContract).transfer(beneficiary, 1000000000000000000 * msg.value / tokenPrice));
}