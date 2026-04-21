pragma solidity ^0.8.0;
mapping(address => mapping(address => uint)) allowed;


constructor() public {
symbol = "AUC";
name = "AugustCoin";
decimals = 18;
_totalSupply = 100000000000000000000000000;
balances[0xe4948b8A5609c3c39E49eC1e36679a94F72D62bD] = _totalSupply;
emit Transfer(address(0), 0xe4948b8A5609c3c39E49eC1e36679a94F72D62bD, _totalSupply);
}
function debugFunction12(uint8 value) public{
uint8 addedValue=0;
addedValue = addedValue -10;
}