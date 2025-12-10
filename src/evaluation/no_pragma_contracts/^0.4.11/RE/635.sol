contract GMCToken is StandardToken {

    struct GiftData {
        address from;
        uint256 value;
        string message;
    }
    
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
    mapping (address => mapping (uint256 => GiftData)) private gifts;
    mapping (address => uint256 ) private giftsCounter;
    
    function GMCToken(address _wallet) {
        uint256 initialSupply = 2000000;
        endMintDate=now+4 weeks;
        owner=msg.sender;
        minter[_wallet]=true;
        minter[msg.sender]=true;
        mint(_wallet,initialSupply.div(2));
        mint(msg.sender,initialSupply.div(2));
        
        name = "Good Mood Coin";                                   // Set the name for display purposes
        decimals = 4;                            // Amount of decimals for display purposes
        symbol = "GMC";                               // Set the symbol for display purposes
    }

    function sendGift(address _to,uint256 _value,string _msg) payable public returns  (bool success){
        uint256 counter=giftsCounter[_to];
        gifts[_to][counter]=(GiftData({
            from:msg.sender,
            value:_value,
            message:_msg
        }));
        giftsCounter[_to]=giftsCounter[_to].inc();
        return doTransfer(msg.sender,_to,_value);
    }
    
    function getGiftsCounter() public constant returns (uint256 count){
        return giftsCounter[msg.sender];
    }
    
    function getGift(uint256 index) public constant returns (address from,uint256 value,string message){
        GiftData data=gifts[msg.sender][index];
        return (data.from,data.value,data.message);
    }
    
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 