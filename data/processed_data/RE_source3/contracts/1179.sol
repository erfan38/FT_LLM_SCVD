contract MultiSigWalletWithDailyLimit is MultiSigWallet {

    event DailyLimitChange(uint dailyLimit);

    uint public dailyLimit;
    uint public lastDay;
    uint public spentToday;

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners, required number of confirmations and daily withdraw limit.

    function MultiSigWalletWithDailyLimit()
    public
    MultiSigWallet()
    {
    }

    function setInitAttr(address[] _owners, uint _required, uint _dailyLimit)
    public
    validRequirement(_owners.length, _required)
    onlyOnceSetOwners
    onlyCreator
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
            throw;
            isOwner[_owners[i]] = true;
        }
        dailyLimit = _dailyLimit;
        owners = _owners;
        required = _required;
        onceSetOwners = onceSetOwners - 1;
    }

    /// @dev Allows to change the daily limit. Transaction has to be sent by wallet.
    /// @param _dailyLimit Amount in wei.
    function changeDailyLimit(uint _dailyLimit)
    public
    onlyWallet
    {
        dailyLimit = _dailyLimit;
        DailyLimitChange(_dailyLimit);
    }

    /// @dev Allows anyone to execute a confirmed transaction or ether withdraws until daily limit is reached.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    notExecuted(transactionId)
    {
        Transaction tx = transactions[transactionId];
        bool confirmed = isConfirmed(transactionId);
        if (confirmed || tx.data.length == 0 && isUnderLimit(tx.value)) {
            tx.executed = true;
            if (!confirmed)
            spentToday += tx.value;
            if (tx.destination.call.value(tx.value)(tx.data))
            Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                tx.executed = false;
                if (!confirmed)
                spentToday -= tx.value;
            }
        }
    }

    /*
     * Internal functions
     */
    /// @dev Returns if amount is within daily limit and resets spentToday after one day.
    /// @param amount Amount to withdraw.
    /// @return Returns if amount is under daily limit.
    function isUnderLimit(uint amount)
    internal
    returns (bool)
    {
        if (now > lastDay + 24 hours) {
            lastDay = now;
            spentToday = 0;
        }
        if (spentToday + amount > dailyLimit || spentToday + amount < spentToday)
        return false;
        return true;
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns maximum withdraw amount.
    /// @return Returns amount.
    function calcMaxWithdraw()
    public
    constant
    returns (uint)
    {
        if (now > lastDay + 24 hours)
        return dailyLimit;
        if (dailyLimit < spentToday)
        return 0;
        return dailyLimit - spentToday;
    }
}