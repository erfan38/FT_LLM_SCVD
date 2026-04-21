pragma solidity ^0.8.0;
function fundPrize() onlyOwner public {
uint256 counted = winBalanceTotal + bossBalance + jackpotBalance + ntsBalance + prizeBalance;
uint256 uncounted = address(this).balance - counted;

require(uncounted > 0);

prizeBalance += uncounted;
emit OnPrizeFunded(uncounted);
}