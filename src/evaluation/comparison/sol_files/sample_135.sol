pragma solidity ^0.8.0;
function changetradingFee(uint tradingFee_) public onlyOwner{
tradingFee = tradingFee_;
}