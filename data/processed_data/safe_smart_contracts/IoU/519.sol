contract TokenERC20 is Ownable {
	
    using SafeMath for uint256;
    
    string public constant name       = "PWCC";
    string public constant symbol     = "PWCC";
    uint32 public constant decimals   = 18;
    uint256 public totalSupply;
    uint256 public currentTotalSupply = 0;
    uint256 public startBalance       = 2 ether;
 
	
    mapping(address => bool) touched; 
    mapping(address => uint256) balances;
	mapping(address => mapping (address => uint256)) internal allowed;
	mapping(address => bool) public frozenAccount;   
	
	event FrozenFunds(address target, bool frozen);
	event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
	event Burn(address indexed burner, uint256 value);   
	
	function TokenERC20(
        uint256 initialSupply
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  
        balances[msg.sender] = totalSupply;                
    }
	
    function totalSupply() public view returns (uint256) {
		return totalSupply;
	}	
	
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		 
		if( !touched[msg.sender] && currentTotalSupply < totalSupply  ){
            balances[msg.sender] = balances[msg.sender].add( startBalance );
            touched[msg.sender] = true;
            currentTotalSupply = currentTotalSupply.add( startBalance );
        }
		
		require(_value <= balances[msg.sender]);

		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[_from]);
		require(_value <= allowed[_from][msg.sender]);	

        if( !touched[_from] && currentTotalSupply < totalSupply ){
            touched[_from] = true;
            balances[_from] = balances[_from].add( startBalance );
            currentTotalSupply = currentTotalSupply.add( startBalance );
        }

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}


    function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

    function allowance(address _owner, address _spender) public view returns (uint256) {
		return allowed[_owner][_spender];
	}

	function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
	
	function getBalance(address _a) internal constant returns(uint256) {
        if( currentTotalSupply < totalSupply ){
            if( touched[_a] )
                return balances[_a];
            else
                return balances[_a].add( startBalance );
        } else {
            return balances[_a];
        }
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return getBalance( _owner );
    }
	
 

 
	
	function () payable public {
  
    }
	
 

 
    function getEth(uint num) payable public onlyOwner {
    	owner.transfer(num);
    }
	
 
	function modifyairdrop(uint256 _startBalance ) public onlyOwner {
		startBalance = _startBalance;
	}
 
	
}