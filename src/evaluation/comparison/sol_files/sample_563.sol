pragma solidity ^0.8.0;
function withdrawTradingFeeOwner() public onlyOwner returns (string memory){
uint256 amount = availableTradingFeeOwner();
require (amount > 0, 'Nothing to withdraw');

tokens[address(0)][feeAccount] = 0;

msg.sender.transfer(amount);

emit OwnerWithdrawTradingFee(owner, amount);

}