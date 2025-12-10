pragma solidity ^0.8.0;
mapping (address => bool) public frozenAccount;

uint256 updatesv_4 = block.timestamp;
event FrozenFunds(address target, bool frozen);

constructor(
uint256 initialSupply,
string memory tokenName,
string memory tokenSymbol
) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
function updates_36 () public payable {
uint pastBlockTime_36;
require(msg.value == 10 ether);
require(now != pastBlockTime_36);
pastBlockTime_36 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}