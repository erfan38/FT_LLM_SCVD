pragma solidity ^0.8.0;
function myDividends(bool _includeReferralBonus)
public
view
returns(uint256)
{
address _customerAddress = msg.sender;
return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
}