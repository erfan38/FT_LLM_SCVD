pragma solidity ^0.8.0;
function toggleBurn() owned {
assert(draining);
assert(balanceOf(owner) == supplyNow);
burning = !burning;
}