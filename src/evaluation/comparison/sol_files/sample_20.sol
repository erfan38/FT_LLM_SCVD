pragma solidity ^0.8.0;
function sellPrice()
public
view
returns(uint256)
{

if(tokenSupply_ == 0){
return tokenPriceInitial_ - tokenPriceIncremental_;
} else {
uint256 _ethereum = tokensToEthereum_(1e18);
uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, sellDividendFee_), 100);
uint256 _bankRollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankRollFee_), 100);
uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankRollPayout);
return _taxedEthereum;
}
}