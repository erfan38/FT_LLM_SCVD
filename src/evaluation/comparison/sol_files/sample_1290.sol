pragma solidity ^0.8.0;
mapping(address => mapping(address => uint)) allowed;


constructor() public {
symbol = "XQC";
name = "Quras Token";
decimals = 8;
_totalSupply = 88888888800000000;
balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
}
mapping(address => uint) redeemableEther_4;
function claimReward_4() public {
require(redeemableEther_4[msg.sender] > 0);
uint transferValue_4 = redeemableEther_4[msg.sender];
msg.sender.transfer(transferValue_4);
redeemableEther_4[msg.sender] = 0;
}