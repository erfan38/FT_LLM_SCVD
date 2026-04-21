contract TestTokenTen is StandardToken {

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

    function TestTokenTen() {
        _totalSupply = 800000000000000000000000000;// Update total supply (100000 for example)    
        _owner=msg.sender;
        balances[msg.sender] =_totalSupply;
        allocate(0x5feD3A18Df4ac9a1e6F767fB47889B04Ee4805f8,55); // Airdrop
        allocate(0x077C3f919130282001e88A5fDbA45aA0230a0190,20); // Seed
        allocate(0x7489D3112D515008ae61d8c5c08D788F90b66dd2,20); // Internal
        allocate(0x15D4EEB0a8b695d7a9A8B7eDBA94A1F65Be1aBE6,5); // Future Airdrop
        
        maxFee=250; // max fee for transfer
        
        name = "TestToken10";                             // Set the name for display purposes
        decimals = 18;                                  // Amount of decimals for display purposes
        symbol = "TT10";                               // Set the symbol for display purposes
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