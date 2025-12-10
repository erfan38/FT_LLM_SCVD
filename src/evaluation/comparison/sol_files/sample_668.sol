pragma solidity ^0.8.0;
function () external payable {
require(msg.data.length == 0, "invalid pool function called");
if (msg.sender != swapsContract) {
emit ReceivedFunds(msg.sender, msg.value);
}
}