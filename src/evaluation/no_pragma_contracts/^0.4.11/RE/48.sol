contract ChooChooCoin is StandardToken { 

    /* Public variables of the token */

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;
    uint256 public totalEthInWei; 
    address public fundsWallet;

    //constructor function 
    function ChooChooCoin() {
        balances[msg.sender] = 500000000000000000000000000;
        totalSupply = 500000000000000000000000000;
        name = "Choo Choo Coin";
        decimals = 18;
        symbol = "Choo";
        unitsOneEthCanBuy = 5800;
        fundsWallet = msg.sender;
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        emit Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 