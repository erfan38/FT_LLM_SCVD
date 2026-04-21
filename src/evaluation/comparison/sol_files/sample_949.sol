pragma solidity ^0.8.0;
function withdrawAllFunds(address payable _to) public onlyOwner returns (bool success) {
return withdrawFunds(_to, availableFunds());
}