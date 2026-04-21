pragma solidity ^0.8.0;
function ownerUpdateContractBalance(uint newContractBalanceInWei) public
onlyOwner
{
contractBalance = newContractBalanceInWei;
}