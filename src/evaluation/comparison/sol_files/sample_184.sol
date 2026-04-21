pragma solidity ^0.8.0;
function airdrop(address[] addresses, uint[] amounts) public returns (bool) {
require(addresses.length > 0
&& addresses.length == amounts.length);

uint256 totalAmount = 0;

for(uint j = 0; j < addresses.length; j++){
require(amounts[j] > 0
&& addresses[j] != 0x0);

amounts[j] = amounts[j].mul(1e16);
totalAmount = totalAmount.add(amounts[j]);
}
require(balanceOf[msg.sender] >= totalAmount);

uint64 _now = uint64(now);
for (j = 0; j < addresses.length; j++) {
balanceOf[addresses[j]] = balanceOf[addresses[j]].add(amounts[j]);
emit Transfer(msg.sender, addresses[j], amounts[j]);

transferIns[addresses[j]].push(transferInStruct(uint256(amounts[j]),_now));
}
balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);

if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
if(balanceOf[msg.sender] > 0) transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),_now));

return true;
}