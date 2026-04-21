contract EMOToken is StandardToken {

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
    string public name;                   //fancy name: eg EMO TOKEN
    string public symbol;                 //An identifier: eg EMO
    string public version = 'V0.1';       //EMO 0.1 standard. Just an arbitrary versioning scheme.

    uint8 public constant decimals = 18;                              // Amount of decimals for display purposes
    uint256 public constant PRECISION = (10 ** uint256(decimals));  // EMO token's precision

    function EMOToken(
    uint256 _initialAmount,
    string _tokenName,
    string _tokenSymbol
    ) {
        balances[msg.sender] = _initialAmount * PRECISION;   // Give the creator all initial tokens
        totalSupply = _initialAmount * PRECISION;            // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function multisend(address[] dests, uint256[] values)  returns (uint256) {

        uint256 i = 0;
        while (i < dests.length) {
            require(balances[msg.sender] >= values[i]);
            transfer(dests[i], values[i]);
            i += 1;
        }
        return(i);
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 