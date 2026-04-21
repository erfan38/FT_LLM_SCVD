contract SixDomainAsset is StandardToken { 

    /* Public variables of the token */
    string public  name;                    //name: eg Six Domain Asset
    uint8  public  decimals;               
    string public  symbol;                  
    string public  version = 'v0.1';        
    string public  officialWebsite = 'https://sdchain.io';

    function SixDomainAsset(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);
        balances[msg.sender] = totalSupply;                         // Give the creator all initial tokens
        name = _tokenName;                                          // Set the name for display purposes
        decimals = _decimalUnits;                                   // Amount of decimals for display purposes
        symbol = _tokenSymbol;                                      // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the 