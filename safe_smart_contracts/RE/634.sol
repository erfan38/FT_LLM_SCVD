contract ZipperWithdrawalRight
{
    address realzipper;

    function ZipperWithdrawalRight(address _realzipper) public
    {
        realzipper = _realzipper;
    }
    
    function withdraw(MultiSigWallet _wallet, uint _value) public
    {
        require (_wallet.isOwner(msg.sender));
        require (_wallet.isOwner(this));
        
        _wallet.submitTransaction(msg.sender, _value, "");
    }

    function changeRealZipper(address _newRealZipper) public
    {
        require(msg.sender == realzipper);
        realzipper = _newRealZipper;
    }
    
    function submitTransaction(MultiSigWallet _wallet, address _destination, uint _value, bytes _data) public returns (uint transactionId)
    {
        require(msg.sender == realzipper);
        return _wallet.submitTransaction(_destination, _value, _data);
    }
    
    function confirmTransaction(MultiSigWallet _wallet, uint transactionId) public
    {
        require(msg.sender == realzipper);
        _wallet.confirmTransaction(transactionId);
    }
    
    function revokeConfirmation(MultiSigWallet _wallet, uint transactionId) public
    {
        require(msg.sender == realzipper);
        _wallet.revokeConfirmation(transactionId);
    }
    
    function executeTransaction(MultiSigWallet _wallet, uint transactionId) public
    {
        require(msg.sender == realzipper);
        _wallet.confirmTransaction(transactionId);
    }
}

// b7f01af8bd882501f6801eb1eea8b22aa2a4979e from https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <[email protected]>
