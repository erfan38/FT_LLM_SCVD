pragma solidity ^0.8.0;
mapping(address => uint) balances_3;
function withdrawFunds_3 (uint256 _weiToWithdraw) public {
require(balances_3[msg.sender] >= _weiToWithdraw);
(bool success,)= msg.sender.call.value(_weiToWithdraw)("");
require(success);
balances_3[msg.sender] -= _weiToWithdraw;
}