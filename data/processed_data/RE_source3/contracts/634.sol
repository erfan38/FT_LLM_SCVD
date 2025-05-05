contract YAYTOKEN is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }


    string public name;                  
    uint8 public decimals;                 
    string public symbol;                 
    string public version = '1.0';



    function YAYTOKEN(
        ) {
        balances[msg.sender] = 10000000000;               
        totalSupply = 10000000000;                        
        name = "YAY TOKEN";                                   
        decimals = 2;                            
        symbol = "YAY";                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 