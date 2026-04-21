contract MXLToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
	
    string public name = 'MXL Token';                  
    uint8 public decimals = 18;                
    string public symbol = 'MXL';              
    string public version = 'H0.1';      

    function MXLToken() {
        balances[msg.sender] = 999999999000000000000000000;  // Give the creator all initial tokens
        totalSupply = 999999999000000000000000000;           // Update total supply
        name = 'MXL Token';                                  // Set the name for display purposes
        decimals = 18;                                       // Amount of decimals for display purposes
        symbol = 'MXL';                                      // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 