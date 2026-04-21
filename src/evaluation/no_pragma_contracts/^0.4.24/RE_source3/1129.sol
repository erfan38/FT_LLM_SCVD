contract TGEToken is MintableToken {
    string public name;       
    uint8 public decimals = 18;                
    string public symbol;                 
    string public version = "H0.1";
    
    function TGEToken(
        string _tokenName,
        string _tokenSymbol
        ) {
        name = _tokenName;
        symbol = _tokenSymbol;
    }
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 