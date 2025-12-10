contract RawToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */

    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.
 
    function RawToken(
        ) {
        balances[msg.sender] = 42000000;             // Give the owner 0 initial tokens 
        totalSupply = 42000000;                 // Update total supply 
        name = "BBK Tobacco & Foods LLP";       // Set the name for display purposes
        decimals = 0;                           // Amount of decimals for display purposes
        symbol = "RAW";                         // Set the symbol for display purposes
     
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 