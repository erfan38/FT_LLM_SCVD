pragma solidity ^0.8.0;
function transfer(address _toAddress, uint256 _amountOfTokens, bytes _data)
onlyBagholders()
public
returns(bool)
{

require(isContract(_toAddress));

address _customerAddress = msg.sender;




require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);


if(myDividends(true) > 0) withdraw();


tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);


payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);

ERC223ReceivingContract _contract = ERC223ReceivingContract(_toAddress);
_contract.tokenFallback(msg.sender, _amountOfTokens, _data);



emit Transfer(_customerAddress, _toAddress, _amountOfTokens, _data);


return true;
}