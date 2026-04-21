pragma solidity ^0.8.0;
function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
string[] memory dynargs = new string[](3);
dynargs[0] = args[0];
dynargs[1] = args[1];
dynargs[2] = args[2];
return oraclize_query(datasource, dynargs);
}