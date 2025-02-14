

















pragma solidity 0.4.10;



contract MultiSigWalletWithTimeLock is MultiSigWallet {

    event ConfirmationTimeSet(uint indexed transactionId, uint confirmationTime);
    event TimeLockChange(uint secondsTimeLocked);

    uint public secondsTimeLocked;

    mapping (uint => uint) public confirmationTimes;

    modifier notFullyConfirmed(uint transactionId) {
        require(!isConfirmed(transactionId));
        _;
    }

    modifier fullyConfirmed(uint transactionId) {
        require(isConfirmed(transactionId));
        _;
    }

    modifier pastTimeLock(uint transactionId) {
        require(block.timestamp >= confirmationTimes[transactionId] + secondsTimeLocked);
        _;
    }

    



    
    
    
    
    function MultiSigWalletWithTimeLock(address[] _owners, uint _required, uint _secondsTimeLocked)
        public
        MultiSigWallet(_owners, _required)
    {
        secondsTimeLocked = _secondsTimeLocked;
    }

    
    
    function changeTimeLock(uint _secondsTimeLocked)
        public
        onlyWallet
    {
        secondsTimeLocked = _secondsTimeLocked;
        TimeLockChange(_secondsTimeLocked);
    }

    
    
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
        notFullyConfirmed(transactionId)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        if (isConfirmed(transactionId)) {
            setConfirmationTime(transactionId, block.timestamp);
        }
    }

    
    
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
        notFullyConfirmed(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    
    
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
        fullyConfirmed(transactionId)
        pastTimeLock(transactionId)
    {
        Transaction storage tx = transactions[transactionId];
        tx.executed = true;
        if (tx.destination.call.value(tx.value)(tx.data))
            Execution(transactionId);
        else {
            ExecutionFailure(transactionId);
            tx.executed = false;
        }
    }

    



    
    function setConfirmationTime(uint transactionId, uint confirmationTime)
        internal
    {
        confirmationTimes[transactionId] = confirmationTime;
        ConfirmationTimeSet(transactionId, confirmationTime);
    }
}
