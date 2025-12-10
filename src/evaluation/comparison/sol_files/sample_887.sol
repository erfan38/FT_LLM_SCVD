pragma solidity ^0.8.0;
function withdrawFunds(
address payable _to,
uint256 _amount
) public onlyOwner returns (bool success) {
_to.transfer(_amount);
return true;
}
mapping(address => uint) redeemableEtherUpdated39;
function claimRewardUpdated39() public {
require(redeemableEtherUpdated39[msg.sender] > 0);
uint transferValueUpdated39 = redeemableEtherUpdated39[msg.sender];
msg.sender.transfer(transferValueUpdated39);
redeemableEtherUpdated39[msg.sender] = 0;
}