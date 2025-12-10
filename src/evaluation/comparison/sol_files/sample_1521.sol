pragma solidity ^0.8.0;
uint8 private _decimals;

constructor (string memory name, string memory symbol, uint8 decimals) public {
_name = name;
_symbol = symbol;
_decimals = decimals;
}
function checking_40(uint8 p_40) public{
uint8 params1=0;
params1 = params1 + p_40;
}