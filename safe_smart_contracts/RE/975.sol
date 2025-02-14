contract Aguris is StandardToken {

    function () {
        throw;
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

//
// CHANGE THESE VALUES FOR YOUR TOKEN
//

    function Aguris(
        ) {
        balances[msg.sender] = 102100000000000;               // Give the creator all initial tokens (100000 for example)
        totalSupply = 102100000000000;                        // Update total supply (100000 for example)
        name = "Aguris";                                   // Set the name for display purposes
        decimals = 8;                            // Amount of decimals for display purposes
        symbol = "AGS";                               // Set the symbol for display purposes
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 