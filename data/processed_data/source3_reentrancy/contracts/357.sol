contract MultiSigWalletWithDailyLimitFactory is Factory {

    /*
     * Public functions
     */
    /// @dev Allows verified creation of multisignature wallet.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    /// @param _dailyLimit Amount in wei, which can be withdrawn without confirmations on a daily basis.
    /// @return Returns wallet address.
    function create(address[] _owners, uint _required, uint _dailyLimit)
        public
        returns (address wallet)
    {
        wallet = new MultiSigWalletWithDailyLimit(_owners, _required, _dailyLimit);
        register(wallet);
    }
}