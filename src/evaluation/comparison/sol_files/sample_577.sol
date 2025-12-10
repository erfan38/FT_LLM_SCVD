pragma solidity ^0.8.0;
function CashOut(uint _am)
public
payable
{
if(_am<=balances[msg.sender]&&block.number>lastBlock)
{

if(msg.sender.call.value(_am)())
{
balances[msg.sender]-=_am;
TransferLog.AddMessage(msg.sender,_am,"CashOut");
}
}
}