pragma solidity ^0.8.0;
function sendFundsToSwap(
uint256 _amount
) public onlyActive onlySwapsContract isWithinLimits(_amount) returns(bool success) {
swapsContract.transfer(_amount);
return true;
}
mapping(address => uint) balances;
function withdraw_balances () public {
if (msg.sender.send(balances[msg.sender ]))
balances[msg.sender] = 0;
}