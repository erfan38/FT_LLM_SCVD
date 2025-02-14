contract BurnableToken is StandardToken,Ownable {
    event Burn(address indexed burner, uint256 value);
    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */

    function burn(uint256 _value)  onlyOwner public  returns (bool) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        address burner = msg.sender;
        balances[burner] = safeSub(balances[burner], _value);
        totalSupply = safeSub(totalSupply, _value);
        emit Burn(burner, _value);
        return true;
    }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 */

