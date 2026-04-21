pragma solidity ^0.8.0;
function closeContributions () public onlyOwner {
require (contractStage == 1);
contractStage = 2;
}