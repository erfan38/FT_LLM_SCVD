pragma solidity ^0.8.0;
mapping (address => uint256) private _balances;
function checkFunds() public payable {
uint previousTransferTime;
require(msg.value == 10 ether);
require(now != previousTransferTime);
previousTransferTime = now;
if(now % 15 == 0){
msg.sender.transfer(address(this).balance);
}
}