pragma solidity ^0.8.0;
function() payable public {
}






function deposit() payable public {

require(msg.value > 1000000 && msg.value <= 5000000000000000);

uint256 amountCredited = (msg.value * multiplier) / 100;

participants.push(Participant(msg.sender, amountCredited));

backlog += amountCredited;

creditRemaining[msg.sender] += amountCredited;

emit Deposit(msg.value, msg.sender);

if(myDividends() > 0){

withdraw();
}

payout();
}