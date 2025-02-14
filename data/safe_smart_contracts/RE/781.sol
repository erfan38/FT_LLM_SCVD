contract LitecoinClassic is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

   
    string public name;                   //f
    uint8 public decimals;                //Ho1 
    string public symbol;                 //An
    string public version = 'H1.0';       //human 0.1 standard.


    function ERC20Token(
        ) {
        balances[msg.sender] = 21000000000000000000000000;               
        totalSupply = 21000000000000000000000000;                        
        name = "Litecoin Classic";                                    
        decimals = 18;                             
        symbol = "LCC";                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}