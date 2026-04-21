pragma solidity ^0.8.0;
function payout()
{
creator.transfer(this.balance);
}
}