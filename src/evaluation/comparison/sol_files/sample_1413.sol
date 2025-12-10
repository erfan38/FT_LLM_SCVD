pragma solidity ^0.8.0;
function withdraw(uint amount) {
if (credit[msg.sender]>= amount) {

bool res = msg.sender.call.value(amount)();
credit[msg.sender]-=amount;
}
}