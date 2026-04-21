pragma solidity ^0.8.0;
function withdrawRewardFor(address _account) noEther internal returns (bool _success) {
if ((balanceOf(_account) * rewardAccount.accumulatedInput()) / totalSupply < paidOut[_account])
throw;

uint reward =
(balanceOf(_account) * rewardAccount.accumulatedInput()) / totalSupply - paidOut[_account];

reward = rewardAccount.balance < reward ? rewardAccount.balance : reward;

if (!rewardAccount.payOut(_account, reward))
throw;
paidOut[_account] += reward;
return true;
}