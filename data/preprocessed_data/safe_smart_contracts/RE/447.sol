contract BurnToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Function to burn tokens.
     * @param _burner The address of token holder.
     * @param _value The amount of token to be burned.
     */
    function burnFunction(address _burner, uint256 _value) internal returns (bool) {
        require(_value > 0);
		require(_value <= balances[_burner]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[_burner] = balances[_burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(_burner, _value);
		return true;
    }
    
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
	function burn(uint256 _value) public returns(bool) {
        return burnFunction(msg.sender, _value);
    }
	
	/**
	* @dev Burns tokens from one address
	* @param _from address The address which you want to burn tokens from
	* @param _value uint256 the amount of tokens to be burned
	*/
	function burnFrom(address _from, uint256 _value) public returns (bool) {
		require(_value <= allowed[_from][msg.sender]); // check if it has the budget allowed
		burnFunction(_from, _value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		return true;
	}
}

