pragma solidity ^0.4.18;




contract MultiSigWalletWithDailyLimit is MultiSigWallet {

    event DailyLimitChange(uint dailyLimit);

    uint public dailyLimit;
    uint public lastDay;
    uint public spentToday;

    


    
    
    
    
    function MultiSigWalletWithDailyLimit(address[] _owners, uint _required, uint _dailyLimit)
        public
        MultiSigWallet(_owners, _required)
    {
        dailyLimit = _dailyLimit;
    }

    
    
    function changeDailyLimit(uint _dailyLimit)
        public
        onlyWallet
    {
        dailyLimit = _dailyLimit;
        DailyLimitChange(_dailyLimit);
    }

    
    
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        Transaction storage txi = transactions[transactionId];
        bool confirmed = isConfirmed(transactionId);
        if (confirmed || txi.data.length == 0 && isUnderLimit(txi.value)) {
            txi.executed = true;
            if (!confirmed)
                spentToday += txi.value;
            if (txi.destination.call.value(txi.value)(txi.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                txi.executed = false;
                if (!confirmed)
                    spentToday -= txi.value;
            }
        }
    }

    


    
    
    
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