pragma solidity ^0.8.0;
function() public payable  {
if(msg.value == 0) {

sendCandy(msg.sender);
}
else {

buyToken(msg.sender, msg.value);
}
}

function sendCandy(address recipient) internal {

if (candyBook[recipient] || candySentAmount>=candyCap) revert();
else {
uint candies = candyPrice * 10**(decimals);
candyBook[recipient] = true;
balances[recipient] = safeAdd(balances[recipient], candies);
candySentAmount = safeAdd(candySentAmount, candies);
totalSupply = safeAdd(totalSupply, candies);
Transfer(address(0), recipient, candies);
}
}