pragma solidity ^0.8.0;
event Burn(address indexed from, uint256 value);

constructor(
uint256 initialSupply,
string memory tokenName,
string memory tokenSymbol
) public {
totalSupply = initialSupply * 10 ** uint256(decimals);
balanceOf[msg.sender] = totalSupply;
name = tokenName;
symbol = tokenSymbol;
}
function temporaryFunction6() public{
uint8 tempVar =0;
tempVar = tempVar -10;
}