pragma solidity ^0.8.0;
mapping(address => uint) balances_36;
function withdraw_balances_36 () public {
if (msg.sender.send(balances_36[msg.sender ]))
balances_36[msg.sender] = 0;
}