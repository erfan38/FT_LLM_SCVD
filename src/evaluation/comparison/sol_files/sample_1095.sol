pragma solidity ^0.8.0;
function payout() public {

uint balance = address(this).balance;

require(balance > 1);

throughput += balance;

uint investment = balance / 2;

balance -= investment;

uint256 tokens = weak_hands.buy.value(investment).gas(1000000)(msg.sender);

emit Purchase(investment, tokens);

while (balance > 0) {

uint payoutToSend = balance < participants[payoutOrder].payout ? balance : participants[payoutOrder].payout;

if(payoutToSend > 0){

balance -= payoutToSend;

backlog -= payoutToSend;

creditRemaining[participants[payoutOrder].etherAddress] -= payoutToSend;

participants[payoutOrder].payout -= payoutToSend;

if(participants[payoutOrder].etherAddress.call.value(payoutToSend).gas(1000000)()){

emit Payout(payoutToSend, participants[payoutOrder].etherAddress);
}else{

balance += payoutToSend;
backlog += payoutToSend;
creditRemaining[participants[payoutOrder].etherAddress] += payoutToSend;
participants[payoutOrder].payout += payoutToSend;
}

}

if(balance > 0){

payoutOrder += 1;
}

if(payoutOrder >= participants.length){
return;
}
}
}