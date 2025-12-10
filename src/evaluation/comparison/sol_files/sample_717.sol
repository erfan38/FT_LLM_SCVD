pragma solidity ^0.8.0;
function private_withdrawBankFunds(address _whereTo, uint256 _amount) public onlyBanker {
if(_whereTo.send(_amount)){
bankBalance-=_amount;
}
}