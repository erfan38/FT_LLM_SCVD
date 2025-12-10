pragma solidity ^0.8.0;
function withdrawDirectDebit(address debtor) public liquid canUseDirectDebit returns (bool) {
Account storage debtorAccount = accounts[debtor];
DirectDebit storage debit = debtorAccount.instruments[msg.sender].directDebit;
uint256 epoch = (block.timestamp.sub(debit.info.startTime) / debit.info.interval).add(1);
uint256 amount = epoch.sub(debit.epoch).mul(debit.info.amount);
require(amount > 0);
debtorAccount.balance = debtorAccount.balance.sub(amount);
accounts[msg.sender].balance += amount;
debit.epoch = epoch;

emit Transfer(debtor, msg.sender, amount);
return true;
}