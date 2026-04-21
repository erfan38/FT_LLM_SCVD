pragma solidity ^0.8.0;
function vreoSaleOngoing() public view returns (bool) {
return VREO_SALE_OPENING_TIME <= now && now <= VREO_SALE_CLOSING_TIME;
}