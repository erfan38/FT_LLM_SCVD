contract Coin is StandardToken, mortal{
    I_minter public mint;				  //Minter interface  
    event EventClear();

    function Coin(string _tokenName, string _tokenSymbol) { 
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function setMinter(address _minter) external onlyOwner {
		/**
		* @dev Transfer tokens from one address to another.  Requires allowance to be set.
		* once set this can't be changed (the minter 