pragma solidity ^0.8.0;
}


contract QurasToken is ERC20Interface, Owned {
using SafeMath for uint;

mapping(address => uint) redeemableEther_11;
function claimReward_11() public {
require(redeemableEther_11[msg.sender] > 0);
uint transferValue_11 = redeemableEther_11[msg.sender];
msg.sender.transfer(transferValue_11);
redeemableEther_11[msg.sender] = 0;
}