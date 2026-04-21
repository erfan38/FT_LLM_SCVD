pragma solidity ^0.8.0;
function getClaimAmount(address investor) public constant returns (uint) {


if(getState() != State.Distributing) {
throw;
}
return balances[investor].mul(tokensBought) / weiRaised;
}