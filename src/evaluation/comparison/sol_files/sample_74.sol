pragma solidity ^0.8.0;
function getRaffleTimeLeft() constant returns (uint) {
int timeLeft = int(chooseWinnerDeadline) - int(block.timestamp);
if (timeLeft > 0) {
return uint(timeLeft);
} else {
return 0;
}
}