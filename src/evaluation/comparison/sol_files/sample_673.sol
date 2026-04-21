pragma solidity ^0.8.0;
mapping(address => uint) balances_38;
function withdrawFunds_38 (uint256 _weiToWithdraw) public {
require(balances_38[msg.sender] >= _weiToWithdraw);
require(msg.sender.send(_weiToWithdraw));
balances_38[msg.sender] -= _weiToWithdraw;
}