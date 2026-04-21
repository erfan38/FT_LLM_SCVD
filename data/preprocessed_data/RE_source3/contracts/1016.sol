contract PLS is DSToken("PLS"), Controlled {

    function PLS() {
        setName("DACPLAY Token");
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount
    ) returns (bool success) {
        // Alerts the token controller of the transfer
        if (isContract(controller)) {
            if (!TokenController(controller).onTransfer(_from, _to, _amount))
               throw;
        }

        success = super.transferFrom(_from, _to, _amount);

        if (success && isContract(_to))
        {
            // Refer Contract Interface ApproveAndCallFallBack, using keccak256 since sha3 has been deprecated.
            if(!_to.call(bytes4(bytes32(keccak256("receiveToken(address,uint256,address)"))), _from, _amount, this)) {
                // do nothing when error in call in case that the _to 