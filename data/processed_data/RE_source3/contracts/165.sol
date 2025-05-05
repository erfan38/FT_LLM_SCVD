contract RUNEToken is SafeMath
{
    
    // Rune Characteristics
  string  public name = "Rune";
  string  public symbol  = "RUNE";
  uint256   public decimals  = 18;
  uint256 public totalSupply  = 1000000000 * (10 ** decimals);

    // Mapping
  mapping( address => uint256 ) balances_;
  mapping( address => mapping(address => uint256) ) allowances_;
  
  // Minting event
  function RUNEToken() public {
        balances_[msg.sender] = totalSupply;
            emit Transfer( address(0), msg.sender, totalSupply );
    }

  function() public payable { revert(); } // does not accept money
  
  // ERC20
  event Approval( address indexed owner,
                  address indexed spender,
                  uint value );

  event Transfer( address indexed from,
                  address indexed to,
                  uint256 value );


  // ERC20
  function balanceOf( address owner ) public constant returns (uint) {
    return balances_[owner];
  }

  // ERC20
  function approve( address spender, uint256 value ) public
  returns (bool success)
  {
    allowances_[msg.sender][spender] = value;
    emit Approval( msg.sender, spender, value );
    return true;
  }
 
  // recommended fix for known attack on any ERC20
  function safeApprove( address _spender,
                        uint256 _currentValue,
                        uint256 _value ) public
                        returns (bool success) {

    // If current allowance for _spender is equal to _currentValue, then
    // overwrite it with _value and return true, otherwise return false.

    if (allowances_[msg.sender][_spender] == _currentValue)
      return approve(_spender, _value);

    return false;
  }

  // ERC20
  function allowance( address owner, address spender ) public constant
  returns (uint256 remaining)
  {
    return allowances_[owner][spender];
  }

  // ERC20
  function transfer(address to, uint256 value) public returns (bool success)
  {
    bytes memory empty; // null
    _transfer( msg.sender, to, value, empty );
    return true;
  }

  // ERC20
  function transferFrom( address from, address to, uint256 value ) public
  returns (bool success)
  {
    require( value <= allowances_[from][msg.sender] );

    allowances_[from][msg.sender] -= value;
    bytes memory empty;
    _transfer( from, to, value, empty );

    return true;
  }

  // ERC223 Transfer and invoke specified callback
  function transfer( address to,
                     uint value,
                     bytes data,
                     string custom_fallback ) public returns (bool success)
  {
    _transfer( msg.sender, to, value, data );

    if ( isContract(to) )
    {
      ContractReceiver rx = ContractReceiver( to );
      require( address(rx).call.value(0)(bytes4(keccak256(custom_fallback)),
               msg.sender,
               value,
               data) );
    }

    return true;
  }

  // ERC223 Transfer to a 