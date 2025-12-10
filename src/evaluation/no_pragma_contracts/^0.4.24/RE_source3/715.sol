contract EqualToken is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        revert();
    }

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    string public symbol;                 //An identifier: eg SBX
    string public version = 'H1.0';       //human 0.1 standard. Just an arbitrary versioning scheme.

    // Fee info
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";

    function EqualToken() {
        _totalSupply = 800000000000000000000000000;// Update total supply (100000 for example)    
        balances[msg.sender] =_totalSupply;
        allocate(0x1c1bE8B53Bd8b7Dc9d0CE46C335532A43b414372,55); // Airdrop
        allocate(0x55819E6F3C4E72ed63c7C465d4FA6C4dd7681cA9,20); // Seed
        allocate(0x92Ab7CaB1fD2a4581350a94Acf0e5594319db6Ee,20); // Internal
        allocate(0xE165aadFD17CfF20357A301785B968b4FeB9B8b7,5); // Future Airdrop
        
        maxFee=250; // max fee for transfer
        
        name = "Equal Token";                                   // Set the name for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        symbol = "EQL";                               // Set the symbol for display purposes
    }

    function allocate(address _address,uint256 percent) private{
        uint256 bal=_totalSupply.onePercent().mul(percent);
        //balances[_address]=bal;
        withoutFee[_address]=true;
        doTransfer(msg.sender,_address,bal,0);
    }
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 