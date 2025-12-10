pragma solidity ^0.8.0;
function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public
onlyOwner
{
gasForOraclize = newSafeGasToOraclize;
}