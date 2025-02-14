contract VeroFox is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }


    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.


    function VeroFox(
        ) {
        balances[msg.sender] = 1500000000000000;
        totalSupply = 1500000000000000;
        name = "VeroFox";
        decimals = 8;
        symbol = "VFX";
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 