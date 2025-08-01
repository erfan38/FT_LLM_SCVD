contract ABToken is ABStandardToken {

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
    string public version = 'H0.1.1';       //human 0.1 standard + applied blockchain first patch (H0.1.1)

     function ABToken() public {
        totalSupply = 990000000;
        balances[msg.sender] = totalSupply; // Give the creator all initial tokens
        decimals = 4;

        // test
        /*name = "Test Token #1";
        symbol = "TT1";*/
        // livenet (main net)
        name = "Applied Blockchain Token";
        symbol = "ABT";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 