contract JBX is owned
{
  string  public name;        // ERC20
  string  public symbol;      // ERC20
  uint8   public decimals;    // ERC20
  uint256 public totalSupply; // ERC20

  mapping( address => uint256 ) balances_;
  mapping( address => mapping(address => uint256) ) allowances_;

  // ERC20
  event Approval( address indexed owner,
                  address indexed spender,
                  uint value );

  // ERC223, ERC20 plus last parameter
  event Transfer( address indexed from,
                  address indexed to,
                  uint256 value,
                  bytes   indexed data );

  // Ethereum Token
  event Burn( address indexed from, uint256 value );

  function JBX()
  {
    balances_[msg.sender] = uint256(200000000);
    totalSupply = uint256(200000000);
    name = "Jbox";
    decimals = uint8(0);
    symbol = "JBX";
  }

  // Jbox-specific
  function mine( uint256 newTokens ) onlyOwner {
    if (newTokens + totalSupply > 4e9)
      revert();

    totalSupply += newTokens;
    balances_[owner] += newTokens;
    bytes memory empty;
    Transfer( address(this), owner, newTokens, empty );
  }

  function() payable { revert(); } // does not accept money

  // ERC20
  function balanceOf( address owner ) constant returns (uint) {
    return balances_[owner];
  }

  // ERC20
  function approve( address spender, uint256 value ) returns (bool success)
  {
    allowances_[msg.sender][spender] = value;
    Approval( msg.sender, spender, value );
    return true;
  }
 
  // ERC20
  function allowance( address owner, address spender ) constant
  returns (uint256 remaining)
  {
    return allowances_[owner][spender];
  }

  // ERC20
  function transfer(address to, uint256 value)
  {
    bytes memory empty; // null
    _transfer( msg.sender, to, value, empty );
  }

  // ERC20
  function transferFrom( address from, address to, uint256 value )
  returns (bool success)
  {
    require( value <= allowances_[from][msg.sender] );

    allowances_[from][msg.sender] -= value;
    bytes memory empty;
    _transfer( from, to, value, empty );

    return true;
  }

  // Ethereum Token
  function approveAndCall( address spender, uint256 value, bytes context )
  returns (bool success)
  {
    if ( approve(spender, value) )
    {
      tokenRecipient recip = tokenRecipient( spender );
      recip.receiveApproval( msg.sender, value, context );
      return true;
    }
    return false;
  }        

  // Ethereum Token
  function burn( uint256 value ) returns (bool success)
  {
    require( balances_[msg.sender] >= value );
    balances_[msg.sender] -= value;
    totalSupply -= value;

    Burn( msg.sender, value );
    return true;
  }

  // Ethereum Token
  function burnFrom( address from, uint256 value ) returns (bool success)
  {
    require( balances_[from] >= value );
    require( value <= allowances_[from][msg.sender] );

    balances_[from] -= value;
    allowances_[from][msg.sender] -= value;
    totalSupply -= value;

    Burn( from, value );
    return true;
  }

  function _transfer( address from,
                      address to,
                      uint value,
                      bytes data ) internal
  {
    require( to != 0x0 );
    require( balances_[from] >= value );
    require( balances_[to] + value > balances_[to] ); // catch overflow

    balances_[from] -= value;
    balances_[to] += value;

    Transfer( from, to, value, data );
  }

  // ERC223 Transfer and invoke specified callback
  function transfer( address to,
                     uint value,
                     bytes data,
                     string custom_fallback ) returns (bool success)
  {
    _transfer( msg.sender, to, value, data );

    if ( isContract(to) )
    {
      ContractReceiver rx = ContractReceiver( to );
      require( rx.call.value(0)
                  (bytes4(sha3(custom_fallback)), msg.sender, value, data) );
    }

    return true;
  }

  // ERC223 Transfer to a 