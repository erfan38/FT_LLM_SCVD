pragma solidity ^0.8.0;
address public team;

modifier isOwner {
require(owner == msg.sender);
_;
}
uint256 currentTime_4 = block.timestamp;

constructor() public {
owner   = msg.sender;
sale    = 0x071F73f4D0befd4406901AACE6D5FFD6D297c561;
evt     = 0x76535ca5BF1d33434A302e5A464Df433BB1F80F6;
team    = 0xD7EC5D8697e4c83Dc33D781d19dc2910fB165D5C;

saleAmount    = toWei(1000000000);
evtAmount     = toWei(200000000);
teamAmount    = toWei(800000000);
totalSupply  = toWei(2000000000);

require(totalSupply == saleAmount + evtAmount + teamAmount );

balances[owner] = totalSupply;
emit Transfer(address(0), owner, balances[owner]);

transfer(sale, saleAmount);
transfer(evt, evtAmount);
transfer(team, teamAmount);
require(balances[owner] == 0);
}
address winnerAddress31;
function playAddress31(uint startTime) public {
uint currentTime = block.timestamp;
if (startTime + (5 * 1 days) == currentTime){
winnerAddress31 = msg.sender;}}