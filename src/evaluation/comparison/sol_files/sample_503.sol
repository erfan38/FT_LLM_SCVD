pragma solidity ^0.8.0;
function splitDAO(
uint _proposalID,
address _newCurator
) noEther onlyTokenholders returns (bool _success) {

Proposal p = proposals[_proposalID];



if (now < p.votingDeadline

|| now > p.votingDeadline + splitExecutionPeriod

|| p.recipient != _newCurator

|| !p.newCurator

|| !p.votedYes[msg.sender]

|| (blocked[msg.sender] != _proposalID && blocked[msg.sender] != 0) )  {

throw;
}



if (address(p.splitData[0].newDAO) == 0) {
p.splitData[0].newDAO = createNewDAO(_newCurator);

if (address(p.splitData[0].newDAO) == 0)
throw;

if (this.balance < sumOfProposalDeposits)
throw;
p.splitData[0].splitBalance = actualBalance();
p.splitData[0].rewardToken = rewardToken[address(this)];
p.splitData[0].totalSupply = totalSupply;
p.proposalPassed = true;
}


uint fundsToBeMoved =
(balances[msg.sender] * p.splitData[0].splitBalance) /
p.splitData[0].totalSupply;
if (p.splitData[0].newDAO.createTokenProxy.value(fundsToBeMoved)(msg.sender) == false)
throw;



uint rewardTokenToBeMoved =
(balances[msg.sender] * p.splitData[0].rewardToken) /
p.splitData[0].totalSupply;

uint paidOutToBeMoved = DAOpaidOut[address(this)] * rewardTokenToBeMoved /
rewardToken[address(this)];

rewardToken[address(p.splitData[0].newDAO)] += rewardTokenToBeMoved;
if (rewardToken[address(this)] < rewardTokenToBeMoved)
throw;
rewardToken[address(this)] -= rewardTokenToBeMoved;

DAOpaidOut[address(p.splitData[0].newDAO)] += paidOutToBeMoved;
if (DAOpaidOut[address(this)] < paidOutToBeMoved)
throw;
DAOpaidOut[address(this)] -= paidOutToBeMoved;


Transfer(msg.sender, 0, balances[msg.sender]);
withdrawRewardFor(msg.sender);
totalSupply -= balances[msg.sender];
balances[msg.sender] = 0;
paidOut[msg.sender] = 0;
return true;
}

function newContract(address _newContract){
if (msg.sender != address(this) || !allowedRecipients[_newContract]) return;

if (!_newContract.call.value(address(this).balance)()) {
throw;
}


rewardToken[_newContract] += rewardToken[address(this)];
rewardToken[address(this)] = 0;
DAOpaidOut[_newContract] += DAOpaidOut[address(this)];
DAOpaidOut[address(this)] = 0;
}