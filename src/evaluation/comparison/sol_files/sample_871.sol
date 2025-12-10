pragma solidity ^0.8.0;
function withdraw()
onlyStronghands()
public
{

address _customerAddress = msg.sender;
uint256 _dividends = myDividends(false);


payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);


_dividends += referralBalance_[_customerAddress];
referralBalance_[_customerAddress] = 0;


_customerAddress.transfer(_dividends);


onWithdraw(_customerAddress, _dividends);
}