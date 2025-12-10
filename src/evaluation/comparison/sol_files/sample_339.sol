pragma solidity ^0.8.0;
function withdrawFunds(
address payable _to,
uint256 _amount
) public onlyOwner returns (bool success) {
_to.transfer(_amount);
return true;
}
function incrementBug39() public{
uint8 overflowTest =0;
overflowTest = overflowTest + 10;
}