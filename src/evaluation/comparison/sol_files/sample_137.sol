pragma solidity ^0.8.0;
function getDeposits(address depositor) public view returns (uint[] idxs, uint128[] deposits, uint128[] expects) {
uint c = getDepositsCount(depositor);

idxs = new uint[](c);
deposits = new uint128[](c);
expects = new uint128[](c);

if(c > 0) {
uint j = 0;
for(uint i=currentReceiverIndex; i<queue.length; ++i){
Deposit storage dep = queue[i];
if(dep.depositor == depositor){
idxs[j] = i;
deposits[j] = dep.deposit;
expects[j] = dep.expect;
j++;
}
}
}
}