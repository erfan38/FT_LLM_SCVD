

















pragma solidity 0.4.10;



contract MultiSigWalletWithTimeLockExceptRemoveAuthorizedAddress is MultiSigWalletWithTimeLock {

    address public TOKEN_TRANSFER_PROXY_CONTRACT;

    modifier validRemoveAuthorizedAddressTx(uint transactionId) {
        Transaction storage tx = transactions[transactionId];
        require(tx.destination == TOKEN_TRANSFER_PROXY_CONTRACT);
        require(isFunctionRemoveAuthorizedAddress(tx.data));
        _;
    }

    
    
    
    
    
    function MultiSigWalletWithTimeLockExceptRemoveAuthorizedAddress(
        address[] _owners,
        uint _required,
        uint _secondsTimeLocked,
        address _tokenTransferProxy)
        public
        MultiSigWalletWithTimeLock(_owners, _required, _secondsTimeLocked)
    {
        TOKEN_TRANSFER_PROXY_CONTRACT = _tokenTransferProxy;
    }

    
    
    function executeRemoveAuthorizedAddress(uint transactionId)
        public
        notExecuted(transactionId)
        fullyConfirmed(transactionId)
        validRemoveAuthorizedAddressTx(transactionId)
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

    
    
    
    function isFunctionRemoveAuthorizedAddress(bytes data)
        public
        constant
        returns (bool)
    {
        bytes4 removeAuthorizedAddressSignature = bytes4(sha3("removeAuthorizedAddress(address)"));
        for (uint i = 0; i < 4; i++) {
            require(data[i] == removeAuthorizedAddressSignature[i]);
        }
        return true;
    }
}