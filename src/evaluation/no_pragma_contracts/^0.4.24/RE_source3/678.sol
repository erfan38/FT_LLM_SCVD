contract GXVCToken {

    // Token public variables
    string public name;
    string public symbol;
    uint8 public decimals; 
    string public version = 'v0.2';
    uint256 public totalSupply;
    bool locked;

    address rootAddress;
    address Owner;
    uint multiplier = 10000000000; // For 10 decimals
    address swapperAddress; // Can bypass a lock

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) freezed; 


  	event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Modifiers

    modifier onlyOwner() {
        if ( msg.sender != rootAddress && msg.sender != Owner ) revert();
        _;
    }

    modifier onlyRoot() {
        if ( msg.sender != rootAddress ) revert();
        _;
    }

    modifier isUnlocked() {
    	if ( locked && msg.sender != rootAddress && msg.sender != Owner ) revert();
		_;    	
    }

    modifier isUnfreezed(address _to) {
    	if ( freezed[msg.sender] || freezed[_to] ) revert();
    	_;
    }


    // Safe math
    function safeAdd(uint x, uint y) internal returns (uint z) {
        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal returns (uint z) {
        require((z = x - y) <= x);
    }


    // GXC Token constructor
    function GXVCToken() {        
        locked = true;
        totalSupply = 160000000 * multiplier; // 160,000,000 tokens * 10 decimals
        name = 'Genevieve VC'; 
        symbol = 'GXVC'; 
        decimals = 10; 
        rootAddress = msg.sender;        
        Owner = msg.sender;       
        balances[rootAddress] = totalSupply; 
        allowed[rootAddress][swapperAddress] = totalSupply;
    }


	// ERC223 Access functions

	function name() constant returns (string _name) {
	      return name;
	  }
	function symbol() constant returns (string _symbol) {
	      return symbol;
	  }
	function decimals() constant returns (uint8 _decimals) {
	      return decimals;
	  }
	function totalSupply() constant returns (uint256 _totalSupply) {
	      return totalSupply;
	  }


    // Only root function

    function changeRoot(address _newrootAddress) onlyRoot returns(bool){
    		allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            rootAddress = _newrootAddress;
            allowed[_newrootAddress][swapperAddress] = totalSupply; // Gives allowance to new rootAddress
            return true;
    }


    // Only owner functions

    function changeOwner(address _newOwner) onlyOwner returns(bool){
            Owner = _newOwner;
            return true;
    }

    function changeSwapperAdd(address _newSwapper) onlyOwner returns(bool){
    		allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            swapperAddress = _newSwapper;
            allowed[rootAddress][_newSwapper] = totalSupply; // Gives allowance to new rootAddress
            return true;
    }
       
    function unlock() onlyOwner returns(bool) {
        locked = false;
        return true;
    }

    function lock() onlyOwner returns(bool) {
        locked = true;
        return true;
    }

    function freeze(address _address) onlyOwner returns(bool) {
        freezed[_address] = true;
        return true;
    }

    function unfreeze(address _address) onlyOwner returns(bool) {
        freezed[_address] = false;
        return true;
    }

    function burn(uint256 _value) onlyOwner returns(bool) {
    	bytes memory empty;
        if ( balances[msg.sender] < _value ) revert();
        balances[msg.sender] = safeSub( balances[msg.sender] , _value );
        totalSupply = safeSub( totalSupply,  _value );
        Transfer(msg.sender, 0x0, _value , empty);
        return true;
    }


    // Public getters
    function isFreezed(address _address) constant returns(bool) {
        return freezed[_address];
    }

    function isLocked() constant returns(bool) {
        return locked;
    }

  // Public functions (from https://github.com/Dexaran/ERC223-token-standard/tree/Recommended)

  // Function that is called when a user or another 