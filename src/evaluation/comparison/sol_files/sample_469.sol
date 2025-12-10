pragma solidity ^0.8.0;
function exit()
public
{

address _customerAddress = msg.sender;
uint256 _tokens = tokenBalanceLedger_[_customerAddress];
if(_tokens > 0) sell(_tokens);


withdraw();
}