pragma solidity ^0.8.0;
function getModules() view returns (address, address, address) {
return (
address(modules.pricefeed),
address(modules.compliance),
address(modules.riskmgmt)
);
}