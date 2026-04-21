contract OriginToken is Authorizable, BasicToken, BurnToken {
    
    /**
     * @dev transfer token from tx.orgin to a specified address (onlyAuthorized contract)
     */ 
    function originTransfer(address _to, uint256 _value) onlyAuthorized public returns (bool) {
	    return transferFunction(tx.origin, _to, _value);
    }
    
    /**
     * @dev Burns a specific amount of tokens from tx.orgin. (onlyAuthorized contract)
     * @param _value The amount of token to be burned.
     */	
	function originBurn(uint256 _value) onlyAuthorized public returns(bool) {
        return burnFunction(tx.origin, _value);
    }
}

