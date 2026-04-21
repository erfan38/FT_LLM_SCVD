pragma solidity ^0.8.0;
function calcSharePrice() view returns (uint sharePrice) {
(, , , , , sharePrice) = performCalculations();
return sharePrice;
}