pragma solidity ^0.8.0;
function withdraw(uint _amount) {
require(tokens[0][msg.sender] >= _amount);
tokens[0][msg.sender] = safeSub(tokens[0][msg.sender], _amount);
if (!msg.sender.call.value(_amount)()) {
revert();
}
Withdraw(0, msg.sender, _amount, tokens[0][msg.sender]);
}