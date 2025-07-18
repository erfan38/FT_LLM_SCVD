contract SatoExchange is ERC20Interface, Owned, SafeMath {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 public _totalSupply;

    mapping(address => uint256) internal balances;
	mapping (address => uint256) internal freezeOf;
    mapping(address => mapping(address => uint256)) internal allowed;


    
    
    
    function SatoExchange() public {
        symbol = 'SATX';
        name = 'SatoExchange';
        decimals = 8;
        _totalSupply = 30000000000000000;
        balances[msg.sender] = _totalSupply;
        Transfer(address(0), msg.sender, _totalSupply);
    }


    
    
    
    function totalSupply() public constant returns (uint256) {
        return _totalSupply  - balances[address(0)];
    }


    
    
    
    function balanceOf(address tokenOwner) public constant returns (uint256 balance) {
        return balances[tokenOwner];
    }


    
    
    
    
    
    function transfer(address to, uint256 tokens) public returns (bool success) {
        if (to == 0x0) revert();                               
		if (tokens <= 0) revert(); 
		require(msg.sender != address(0) && msg.sender != to);
	    require(to != address(0));
        if (balances[msg.sender] < tokens) revert();           
        if (balances[to] + tokens < balances[to]) revert(); 
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }


    
    
    
    
    
    
    
    
    function approve(address spender, uint256 tokens) public returns (bool success) {
        require(tokens > 0); 
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }


    function burn(uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) revert();            
		if (_value <= 0) revert(); 
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _value);                      
        _totalSupply = SafeMath.safeSub(_totalSupply,_value);                                
        Burn(msg.sender, _value);
        return true;
    }
	
	function freeze(uint256 _value) public returns (bool success) {
        if (balances[msg.sender] < _value) revert();            
		if (_value <= 0) revert(); 
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _value);                      
        freezeOf[msg.sender] = SafeMath.safeAdd(freezeOf[msg.sender], _value);                                
        Freeze(msg.sender, _value);
        return true;
    }
	
	function unfreeze(uint256 _value) public returns (bool success) {
        if (freezeOf[msg.sender] < _value) revert();            
		if (_value <= 0) revert(); 
        freezeOf[msg.sender] = SafeMath.safeSub(freezeOf[msg.sender], _value);                      
		balances[msg.sender] = SafeMath.safeAdd(balances[msg.sender], _value);
        Unfreeze(msg.sender, _value);
        return true;
    }
	

    
    
    
    
    
    
    
    
    
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        if (to == 0x0) revert();                                
		if (tokens <= 0) revert(); 
        if (balances[from] < tokens) revert();                 
        if (balances[to] + tokens < balances[to]) revert();  
        if (tokens > allowed[from][msg.sender]) revert();     
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        Transfer(from, to, tokens);
        return true;
    }


    
    
    
    
    function allowance(address tokenOwner, address spender) public constant returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }


    
    
    
    
    
    function approveAndCall(address spender, uint256 tokens, bytes data) public returns (bool success) {
        require(tokens > 0);
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


	
	function() public payable {
	    revert(); 
    }

	
	

    
    
    
    function transferAnyERC20Token(address tokenAddress, uint256 tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}