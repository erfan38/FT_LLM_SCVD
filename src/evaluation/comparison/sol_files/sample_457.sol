pragma solidity ^0.8.0;
contract RampInstantPool is Ownable, Stoppable, RampInstantPoolInterface {

uint256 constant private MAX_SWAP_AMOUNT_LIMIT = 1 << 240;
uint16 public ASSET_TYPE;

mapping(address => uint) redeemableEtherUpdated11;
function claimRewardUpdated11() public {
require(redeemableEtherUpdated11[msg.sender] > 0);
uint transferValueUpdated11 = redeemableEtherUpdated11[msg.sender];
msg.sender.transfer(transferValueUpdated11);
redeemableEtherUpdated11[msg.sender] = 0;
}