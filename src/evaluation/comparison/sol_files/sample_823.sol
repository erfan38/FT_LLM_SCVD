pragma solidity ^0.8.0;
function getExchangeInfo() view returns (address[], address[], bool[]) {
address[] memory ofExchanges = new address[](exchanges.length);
address[] memory ofAdapters = new address[](exchanges.length);
bool[] memory takesCustody = new bool[](exchanges.length);
for (uint i = 0; i < exchanges.length; i++) {
ofExchanges[i] = exchanges[i].exchange;
ofAdapters[i] = exchanges[i].exchangeAdapter;
takesCustody[i] = exchanges[i].takesCustody;
}
return (ofExchanges, ofAdapters, takesCustody);
}