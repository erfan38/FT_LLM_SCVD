pragma solidity ^0.8.0;
function buy(address _referredBy)
public
payable
returns(uint256)
{

require(tx.gasprice <= 0.05 szabo);
purchaseTokens(msg.value, _referredBy);
}