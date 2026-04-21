pragma solidity ^0.8.0;
function voteToKickoffNewFiscalYear() onlyTokenHolders noEther onlyLocked {


uint _fiscal = currentFiscalYear + 1;

if(!isKickoffEnabled[1]){


}else if(currentFiscalYear <= 3){

if(lastKickoffDate + lastKickoffDateBuffer < now){

}else{

doThrow("kickOff:tooEarly");
return;
}
}else{

doThrow("kickOff:4thYear");
return;
}


supportKickoffQuorum[_fiscal] -= votedKickoff[_fiscal][msg.sender];
supportKickoffQuorum[_fiscal] += balances[msg.sender];
votedKickoff[_fiscal][msg.sender] = balances[msg.sender];


uint threshold = (kickoffQuorumPercent*(tokensCreated + bountyTokensCreated)) / 100;
if(supportKickoffQuorum[_fiscal] > threshold) {
if(_fiscal == 1){

extraBalanceWallet.returnBalanceToMainAccount();


totalInitialBalance = this.balance;
uint fundToReserve = (totalInitialBalance * mgmtFeePercentage) / 100;
annualManagementFee = fundToReserve / 4;
if(!managementFeeWallet.send(fundToReserve)){
doThrow("kickoff:ManagementFeePoolWalletFail");
return;
}

}
isKickoffEnabled[_fiscal] = true;
currentFiscalYear = _fiscal;
lastKickoffDate = now;


managementFeeWallet.payManagementBodyAmount(annualManagementFee);

evKickoff(msg.sender, msg.value, _fiscal);
evIssueManagementFee(msg.sender, msg.value, annualManagementFee, true);
}
}