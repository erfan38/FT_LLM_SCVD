contract StandardMintableToken is MintableToken {
    constructor(address _minter, string _name, string _symbol, uint8 _decimals)
        StandardToken(_name, _symbol, _decimals)
        MintableToken(_minter)
        public
    {
    }
}

 

 
