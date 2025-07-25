contract VVToken is MultiOwner{
	event SubmitTransaction(bytes32 transactionHash);
	event Confirmation(address sender, bytes32 transactionHash);
	event Execution(bytes32 transactionHash);
	event FrozenFunds(address target, bool frozen);
	event Transfer(address indexed from, address indexed to, uint256 value);
	
	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
	uint256 public EthPerToken = 300;
	
	mapping(address => uint256) public balanceOf;
	mapping(address => bool) public frozenAccount;
	mapping (bytes32 => mapping (address => bool)) public Confirmations;
	mapping (bytes32 => Transaction) public Transactions;
	
	struct Transaction {
		address destination;
		uint value;
		bytes data;
		bool executed;
    }
	
	modifier notNull(address destination) {
		require (destination != 0x0);
        _;
    }
	
	modifier confirmed(bytes32 transactionHash) {
		require (Confirmations[transactionHash][msg.sender]);
        _;
    }

    modifier notConfirmed(bytes32 transactionHash) {
		require (!Confirmations[transactionHash][msg.sender]);
        _;
    }
	
	modifier notExecuted(bytes32 TransHash) {
		require (!Transactions[TransHash].executed);
        _;
    }
    
	function VVToken(uint256 initialSupply, string tokenName, uint8 decimalUnits, string tokenSymbol, address[] _owners, uint256 _required) MultiOwner(_owners, _required) public {
		decimals = decimalUnits;				// Amount of decimals for display purposes 
		totalSupply = initialSupply * 10 ** uint256(decimals);
		balanceOf[msg.sender] = totalSupply; 			// Give the creator all initial tokens                    
		name = tokenName; 						// Set the name for display purposes     
		symbol = tokenSymbol; 					// Set the symbol for display purposes    
    }
	
	/* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
		uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
	
	function transfer(address _to, uint256 _value) public {
		_transfer(msg.sender, _to, _value);
	}
	
	function setPrices(uint256 newValue) onlyOwner public {
        EthPerToken = newValue;
    }
    
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }
	
	function() payable {
		revert();
    }
	
	function remainBalanced() public constant returns (uint256){
        return balanceOf[this];
    }
	
	/*Transfer Eth */
	function execute(address _to, uint _value, bytes _data) notNull(_to) onlyOwner external returns (bytes32 _r) {
		_r = addTransaction(_to, _value, _data);
		confirmTransaction(_r);
    }
	
	function addTransaction(address destination, uint value, bytes data) private notNull(destination) returns (bytes32 TransHash){
        TransHash = sha3(destination, value, data);
        if (Transactions[TransHash].destination == 0) {
            Transactions[TransHash] = Transaction({
                destination: destination,
                value: value,
                data: data,
                executed: false
            });
            SubmitTransaction(TransHash);
        }
    }
	
	function addConfirmation(bytes32 TransHash) private onlyOwner notConfirmed(TransHash){
        Confirmations[TransHash][msg.sender] = true;
        Confirmation(msg.sender, TransHash);
    }
	
	function isConfirmed(bytes32 TransHash) public constant returns (bool){
        uint count = 0;
        for (uint i=0; i<owners.length; i++)
            if (Confirmations[TransHash][owners[i]])
                count += 1;
            if (count == ownerRequired)
                return true;
    }
	
	function confirmationCount(bytes32 TransHash) external constant returns (uint count){
        for (uint i=0; i<owners.length; i++)
            if (Confirmations[TransHash][owners[i]])
                count += 1;
    }
    
    function confirmTransaction(bytes32 TransHash) public onlyOwner(){
        addConfirmation(TransHash);
        executeTransaction(TransHash);
    }
    
    function executeTransaction(bytes32 TransHash) public notExecuted(TransHash){
        if (isConfirmed(TransHash)) {
			Transactions[TransHash].executed = true;
            require(Transactions[TransHash].destination.call.value(Transactions[TransHash].value)(Transactions[TransHash].data));
            Execution(TransHash);
        }
    }
	
	function kill() onlyOwner() private {
        selfdestruct(msg.sender);
    }
}