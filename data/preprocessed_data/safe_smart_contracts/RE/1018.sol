contract Coin is StandardToken, mortal{
    I_minter public mint;				  //Minter interface  
    event EventClear();

    function Coin(string _tokenName, string _tokenSymbol, address _minter) { 
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
        changeOwner(_minter);
        mint=I_minter(_minter); 
	}
}

/** @title RiskCoin. */
