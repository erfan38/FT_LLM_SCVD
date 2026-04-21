pragma solidity ^0.8.0;
function calcNav(uint gav, uint unclaimedFees)
view
returns (uint nav)
{
nav = sub(gav, unclaimedFees);
}