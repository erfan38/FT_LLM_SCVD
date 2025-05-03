contract HUGSTOKEN is StandardToken {
    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */
    string public name = "Hugs Tokens";                   //fancy name: eg Simon Bucks
    uint8 public decimals = 0;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol = "HUG";                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

    function HUGSTOKEN(
        ) {
        balances[msg.sender] = 500000;               // Give the creator all initial tokens (100000 for example)
        totalSupply = 500000;                        // Update total supply (100000 for example)
        name = "HUGS TOKEN";                                   // Set the name for display purposes
        decimals = 0;                            // Amount of decimals for display purposes
        symbol = "HUG";                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the 