pragma solidity ^0.8.0;
contract MICRODAO is DAOInterface, Token, TokenCreation {


modifier onlyTokenholders {
if (balanceOf(msg.sender) == 0) throw;
_
}

function MICRODAO(
address _curator,
DAO_Creator _daoCreator,
uint _proposalDeposit,
uint _minTokensToCreate,
uint _closingTime,
address _privateCreation
) TokenCreation(_minTokensToCreate, _closingTime, _privateCreation) {

curator = _curator;
daoCreator = _daoCreator;
proposalDeposit = _proposalDeposit;
rewardAccount = new ManagedAccount(address(this), false);
DAOrewardAccount = new ManagedAccount(address(this), false);
if (address(rewardAccount) == 0)
throw;
if (address(DAOrewardAccount) == 0)
throw;
lastTimeMinQuorumMet = now;
minQuorumDivisor = 5;
proposals.length = 1;

allowedRecipients[address(this)] = true;
allowedRecipients[curator] = true;
}

function () returns (bool success) {
if (now < closingTime + creationGracePeriod && msg.sender != address(extraBalance))
return createTokenProxy(msg.sender);
else
return receiveEther();
}