pragma solidity ^0.8.0;
mapping(address => uint) balances_17;
function withdrawFunds_17 (uint256 _weiToWithdraw) public {
require(balances_17[msg.sender] >= _weiToWithdraw);
(bool success,)=msg.sender.call.value(_weiToWithdraw)("");
require(success);
balances_17[msg.sender] -= _weiToWithdraw;
}