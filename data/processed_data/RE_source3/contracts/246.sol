contract SingularDTVToken is StandardToken {
    string public version = "0.1.0";

    /*
     *  External contracts
     */
    AbstractSingularDTVFund public singularDTVFund;

    /*
     *  Token meta data
     */
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param to Address of token receiver.
    /// @param value Number of tokens to transfer.
    function transfer(address to, uint256 value)
        returns (bool)
    {
        // Both parties withdraw their reward first
        singularDTVFund.softWithdrawRewardFor(msg.sender);
        singularDTVFund.softWithdrawRewardFor(to);
        return super.transfer(to, value);
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param from Address from where tokens are withdrawn.
    /// @param to Address to where tokens are sent.
    /// @param value Number of tokens to transfer.
    function transferFrom(address from, address to, uint256 value)
        returns (bool)
    {
        // Both parties withdraw their reward first
        singularDTVFund.softWithdrawRewardFor(from);
        singularDTVFund.softWithdrawRewardFor(to);
        return super.transferFrom(from, to, value);
    }

    function SingularDTVToken(address sDTVFundAddr, address _wallet, string _name, string _symbol, uint _totalSupply) {
        if(sDTVFundAddr == 0 || _wallet == 0) {
            // Fund and Wallet addresses should not be null.
            revert();
        }

        balances[_wallet] = _totalSupply;
        totalSupply = _totalSupply;

        name = _name;
        symbol = _symbol;

        singularDTVFund = AbstractSingularDTVFund(sDTVFundAddr);

        Transfer(this, _wallet, _totalSupply);
    }
}

