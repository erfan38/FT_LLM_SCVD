contract PLN is StandardToken {

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
    string public name = "Plutaneum";                   //
    uint8 public decimals = 2;                //
    string public symbol = "PLN";                 //
    string public version = 'H1.0';       //

//
// 
//

//

    function PLN(
        ) {
        balances[msg.sender] = 20000000000;               // 
        totalSupply = 20000000000;                        // 
        name = "Plutaneum";                                   // 
        decimals = 2;                            // 
        symbol = "PLN";                               // 
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 