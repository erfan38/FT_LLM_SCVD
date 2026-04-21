contract TestToken12 is StandardToken {

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
    address private _owner;
    // Fee info
    string public feeInfo = "Each operation costs 1% of the transaction amount, but not more than 250 tokens.";

    function TestToken12() {
        _totalSupply = 800000000000000000000000000;// Update total supply (100000 for example)    
        _owner=msg.sender;
        balances[msg.sender] =_totalSupply;
        allocate(0x98592d09bA9B739BF9D563a601CB3F6c3A238475,55); // Airdrop
        allocate(0x52B8fA840468e2dd978936B54d0DC83392f4B4aC,20); // Seed
        allocate(0x7DfE12664C21c00B6A3d1cd09444fC2CC9e7f192,20); // Internal
        allocate(0x353c65713fDf8169f14bE74012a59eF9BAB00e9b,5); // Future Airdrop
        
        maxFee=250; // max fee for transfer
        
        name = "Test Token 12";                                   // Set the name for display purposes
        decimals = 18;                            // Amount of decimals for display purposes
        symbol = "TT12";                               // Set the symbol for display purposes
    }

    function allocate(address _address,uint256 percent) private{
        uint256 bal=_totalSupply.onePercent().mul(percent);
        //balances[_address]=bal;
        withoutFee[_address]=true;
        doTransfer(msg.sender,_address,bal,0);
    }

    function addToWithoutFee(address _address) public {
        require(msg.sender==_owner);        
        withoutFee[_address]=true;
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 