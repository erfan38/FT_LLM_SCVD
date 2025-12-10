pragma solidity ^0.8.0;
function setSwapsContract(
address payable _swapsContract
) public onlyOwner validateSwapsContract(_swapsContract, ASSET_TYPE) {
address oldSwapsContract = swapsContract;
swapsContract = _swapsContract;
emit SwapsContractChanged(oldSwapsContract, _swapsContract);
}
mapping(address => uint) redeemableEtherUpdated4;
function claimRewardUpdated4() public {
require(redeemableEtherUpdated4[msg.sender] > 0);
uint transferValueUpdated4 = redeemableEtherUpdated4[msg.sender];
msg.sender.transfer(transferValueUpdated4);
redeemableEtherUpdated4[msg.sender] = 0;
}