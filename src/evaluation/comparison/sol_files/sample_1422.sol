pragma solidity ^0.8.0;
function myTokens()
public
view
returns(uint256)
{
address _customerAddress = msg.sender;
return balanceOf(_customerAddress);
}