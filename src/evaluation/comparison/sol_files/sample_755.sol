pragma solidity ^0.8.0;
function setERC20ApproveChecking(bool approveChecking) public {
emit SetERC20ApproveChecking(erc20ApproveChecking = approveChecking);
}