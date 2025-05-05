contract CAST is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */
    
    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0';  


    function CAST(
        ) {
        balances[msg.sender] = 75000000 * 100000000;   // Give the creator all initial tokens, 8 zero is 8 Decimals
        totalSupply = 75000000 * 100000000;            // Update total supply, , 8 zero is 8 Decimals
        name = "Crypto Alley Shares";                          // Token Name
        decimals = 8;                                      // Amount of decimals for display purposes
        symbol = "CAST";                                    // Token Symbol
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}