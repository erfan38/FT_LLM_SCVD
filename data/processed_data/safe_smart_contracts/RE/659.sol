contract TripleCoin is StandardToken {

    function () {
        
        throw;
    }
    
    string public name;                  
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';       



    function TripleCoin(
        ) {
        balances[msg.sender] = 23000000000000000000000000;               
        totalSupply = 23000000000000000000000000;                        
        name = "TripleCoin";                                  
        decimals = 18;                            
        symbol = "TIC";
    }


    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}