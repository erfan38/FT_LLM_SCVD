pragma solidity ^0.8.0;
function approveWithdraw(address token, address user) public onlyAdmin {
withdrawAllowance[token][user] = safeAdd(withdrawAllowance[token][user], applyList[token][user]);
applyList[token][user] = 0;
latestApply[token][user] = 0;
}