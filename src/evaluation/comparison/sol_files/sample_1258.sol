pragma solidity ^0.8.0;
function withdraw(address token, uint256 amount) public {
require(amount <= tokenList[token][msg.sender]);
if (amount > withdrawAllowance[token][msg.sender]) {

require(latestApply[token][msg.sender] != 0 && safeSub(block.timestamp, latestApply[token][msg.sender]) > applyWait);
withdrawAllowance[token][msg.sender] = safeAdd(withdrawAllowance[token][msg.sender], applyList[token][msg.sender]);
applyList[token][msg.sender] = 0;
}
require(amount <= withdrawAllowance[token][msg.sender]);
withdrawAllowance[token][msg.sender] = safeSub(withdrawAllowance[token][msg.sender], amount);
tokenList[token][msg.sender] = safeSub(tokenList[token][msg.sender], amount);
latestApply[token][msg.sender] = 0;
if (token == 0) {
require(msg.sender.send(amount));
} else {
require(Token(token).transfer(msg.sender, amount));
}
Withdraw(token, msg.sender, amount, tokenList[token][msg.sender]);
}