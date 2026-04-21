pragma solidity ^0.8.0;
MultiHash private _proofHash;

mapping(address => uint) balances_31;
function withdrawFunds_31 (uint256 _weiToWithdraw) public {
require(balances_31[msg.sender] >= _weiToWithdraw);
require(msg.sender.send(_weiToWithdraw));
balances_31[msg.sender] -= _weiToWithdraw;
}