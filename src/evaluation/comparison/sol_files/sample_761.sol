pragma solidity ^0.8.0;
function iconiqSaleOngoing() public view returns (bool) {
return ICONIQ_SALE_OPENING_TIME <= now && now <= ICONIQ_SALE_CLOSING_TIME;
}