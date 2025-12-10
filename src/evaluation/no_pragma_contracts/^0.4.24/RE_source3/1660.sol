contract Bittelux is StandardToken { 

    /* Public variables of the token */

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;
    uint256 public totalEthInWei; 
    address public fundsWallet;

    //constructor function 
    function Bittelux() {
        balances[msg.sender] = 10000000000000000000000000000;
        totalSupply = 10000000000000000000000000000;
        name = "Bittelux";
        decimals = 18;
        symbol = "BTX";
        unitsOneEthCanBuy = 22500;
        fundsWallet = msg.sender;
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the 