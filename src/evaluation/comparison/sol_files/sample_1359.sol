pragma solidity ^0.8.0;
function retrieveDAOReward(bool _toMembers) external noEther returns (bool _success) {
MICRODAO dao = MICRODAO(msg.sender);

if ((rewardToken[msg.sender] * DAOrewardAccount.accumulatedInput()) /
totalRewardToken < DAOpaidOut[msg.sender])
throw;

uint reward =
(rewardToken[msg.sender] * DAOrewardAccount.accumulatedInput()) /
totalRewardToken - DAOpaidOut[msg.sender];

reward = DAOrewardAccount.balance < reward ? DAOrewardAccount.balance : reward;

if(_toMembers) {
if (!DAOrewardAccount.payOut(dao.rewardAccount(), reward))
throw;
}
else {
if (!DAOrewardAccount.payOut(dao, reward))
throw;
}
DAOpaidOut[msg.sender] += reward;
return true;
}