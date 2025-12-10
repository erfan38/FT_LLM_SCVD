contract GGoken is StandardToken {

    function () public payable {
        require(msg.value > 0 && receivedWei < targetWei);
        require(now > releaseTime);
        receivedWei += msg.value;
        walletAddress.transfer(msg.value);
        NewSale(msg.sender, msg.value);
        assert(receivedWei >= msg.value);
    }

    string public name = "GG Token";                   //fancy name
    uint8 public decimals = 18;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol = "GG";                 //An identifier
    string public version = 'v0.1';       //gg 0.1 standard. Just an arbitrary versioning scheme.

    address public founder; // The address of the founder
    uint256 public targetWei;// The target eth of ico
    uint256 public receivedWei;//The received nummber of eth
    uint256 public releaseTime;//The start time of ico
    uint256 public allocateEndTime;
    address public walletAddress;//Address of wallet

    event NewSale(address indexed _from, uint256 _amount);
    
    
    // The nonce for avoid transfer replay attacks
    mapping(address => uint256) nonces;

    function GGoken(address _walletAddress) public {
        founder = msg.sender;
        walletAddress = _walletAddress;
        releaseTime = 1511695159;
        allocateEndTime = releaseTime + 1 days;
        targetWei = 2 ether;
    }

    /*
     * Proxy transfer gg token. When some users of the ethereum account has no ether,
     * he or she can authorize the agent for broadcast transactions, and agents may charge agency fees
     * @param _from
     * @param _to
     * @param _value
     * @param feeGg
     * @param _v
     * @param _r
     * @param _s
     */
    function transferProxy(address _from, address _to, uint256 _value, uint256 _feeGg,
        uint8 _v,bytes32 _r, bytes32 _s) public returns (bool){

        if(balances[_from] < _feeGg + _value) revert();

        uint256 nonce = nonces[_from];
        bytes32 h = keccak256(_from,_to,_value,_feeGg,nonce);
        if(_from != ecrecover(h,_v,_r,_s)) revert();

        if(balances[_to] + _value < balances[_to]
            || balances[msg.sender] + _feeGg < balances[msg.sender]) revert();
        balances[_to] += _value;
        Transfer(_from, _to, _value);

        balances[msg.sender] += _feeGg;
        Transfer(_from, msg.sender, _feeGg);

        balances[_from] -= _value + _feeGg;
        nonces[_from] = nonce + 1;
        return true;
    }

    /*
     * Proxy approve that some one can authorize the agent for broadcast transaction
     * which call approve method, and agents may charge agency fees
     * @param _from The address which should tranfer gg to others
     * @param _spender The spender who allowed by _from
     * @param _value The value that should be tranfered.
     * @param _v
     * @param _r
     * @param _s
     */
    function approveProxy(address _from, address _spender, uint256 _value,
        uint8 _v,bytes32 _r, bytes32 _s) public returns (bool success) {

        uint256 nonce = nonces[_from];
        bytes32 hash = keccak256(_from,_spender,_value,nonce);
        if(_from != ecrecover(hash,_v,_r,_s)) revert();
        allowed[_from][_spender] = _value;
        Approval(_from, _spender, _value);
        nonces[_from] = nonce + 1;
        return true;
    }


    /*
     * Get the nonce
     * @param _addr
     */
    function getNonce(address _addr) public constant returns (uint256){
        return nonces[_addr];
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 