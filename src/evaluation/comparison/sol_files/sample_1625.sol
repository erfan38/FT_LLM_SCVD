pragma solidity ^0.8.0;
function withdrawDirectDebit(address[] debtors, bool strict) public liquid canUseDirectDebit returns (bool result) {
Account storage receiverAccount = accounts[msg.sender];
result = true;
uint256 total;

for (uint256 i = 0; i < debtors.length; i++) {
address debtor = debtors[i];
Account storage debtorAccount = accounts[debtor];
DirectDebit storage debit = debtorAccount.instruments[msg.sender].directDebit;
uint256 epoch = (block.timestamp.sub(debit.info.startTime) / debit.info.interval).add(1);
uint256 amount = epoch.sub(debit.epoch).mul(debit.info.amount);
require(amount > 0);
uint256 debtorBalance = debtorAccount.balance;

if (amount > debtorBalance) {
if (strict) {
revert();
}
result = false;
emit WithdrawDirectDebitFailure(debtor, msg.sender);
} else {
debtorAccount.balance = debtorBalance - amount;
total += amount;
debit.epoch = epoch;

emit Transfer(debtor, msg.sender, amount);
}
}

receiverAccount.balance += total;
}
}