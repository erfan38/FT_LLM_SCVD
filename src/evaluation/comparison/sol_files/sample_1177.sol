pragma solidity ^0.8.0;
function assignBank(address bank_)
public
onlyOwner
{
bank = bank_;
}