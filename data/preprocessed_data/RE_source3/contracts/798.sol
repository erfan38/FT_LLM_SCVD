contract AditusToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    string public name;                   
    uint8 public decimals;               
    string public symbol;                
    string public version = 'A1.0';   

    function AditusToken(
        ) {
        balances[msg.sender] = 1000000000;               // Give the creator all initial tokens (100000 for example)
        totalSupply = 1000000000;                        // Update total supply (100000 for example)
        name = "Aditus";                                   // Set the name for display purposes
        decimals = 2;                            // Amount of decimals for display purposes
        symbol = "ADI";                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 