pragma solidity ^0.8.0;
function getDepositsCount(address depositor) public view returns (uint) {
uint c = 0;
for(uint i=currentReceiverIndex; i<queue.length; ++i){
if(queue[i].depositor == depositor)
c++;
}
return c;
}