contract ERC20Token is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    */
    string public name;                   //f
    uint8 public decimals;                //Ho1 
    string public symbol;                 //An
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

//l
//l
//l

//l

    function ERC20Token(
        ) {
        balances[msg.sender] = 21000000000000000000000000;               // Give the creator all initial tokens (100000 for example)
        totalSupply = 21000000000000000000000000;                        // Update total supply (100000 for example)
        name = "Litecoin Classic";                                   // Set the name for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        symbol = "LCC";                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 