pragma solidity ^0.8.0;
function pay() private {

uint128 money = uint128(address(this).balance);


for(uint i=currentReceiverIndex; i<queue.length; i++){

Deposit storage dep = queue[i];

if(money >= dep.expect){
dep.depositor.send(dep.expect);
money -= dep.expect;


delete numInQueue[dep.depositor];
delete queue[i];
}else{

dep.depositor.send(money);
dep.expect -= money;
break;
}

if(gasleft() <= 50000)
break;
}

currentReceiverIndex = i;
}