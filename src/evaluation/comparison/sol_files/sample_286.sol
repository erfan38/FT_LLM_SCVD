pragma solidity ^0.8.0;
function withdraw() public {
uint256 balance = address(this).balance;
weak_hands.withdraw.gas(1000000)();
uint256 dividendsPaid = address(this).balance - balance;
dividends += dividendsPaid;
emit Dividends(dividendsPaid);
}