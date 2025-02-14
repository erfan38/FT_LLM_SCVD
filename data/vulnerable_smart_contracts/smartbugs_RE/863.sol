pragma solidity 0.4.21;

contract MultiSigWalletWithDailyLimit is MultiSigWallet {

    event DailyLimitChange(uint dailyLimit);

    uint public dailyLimit;
    uint public lastDay;
    uint public spentToday;

    modifier isNotZero(uint amount) {
        require(amount > 0);
        _;
    }

    


    
    
    
    
    function MultiSigWalletWithDailyLimit(address[] _owners, uint _required, uint _dailyLimit)
        public
        isNotZero(_dailyLimit)
        MultiSigWallet(_owners, _required)
    {
        dailyLimit = _dailyLimit;
    }

    
    
    function changeDailyLimit(uint _dailyLimit)
        public
        onlyWallet
        isNotZero(_dailyLimit)
    {
        dailyLimit = _dailyLimit;
        DailyLimitChange(_dailyLimit);
    }

    
    
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
                Execution(transactionId, tx.reference);
            else {
                ExecutionFailure(transactionId, tx.reference);
                tx.executed = false;
                if (!confirmed)
                    spentToday -= tx.value;
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