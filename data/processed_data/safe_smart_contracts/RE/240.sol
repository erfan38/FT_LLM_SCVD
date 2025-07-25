contract ERC223Token
{
  string  public name;
  string  public symbol;
  uint8   public decimals;
  uint256 public totalSupply;

  mapping( address => uint256 ) balances_;
  mapping( address => mapping(address => uint256) ) allowances_;

  // ERC20
  event Approval( address indexed owner,
                  address indexed spender,
                  uint value );

  event Transfer( address indexed from,
                  address indexed to,
                  uint256 value );
               // bytes    data ); use ERC20 version instead

  function ERC223Token( uint256 initialSupply,
                        string tokenName,
                        uint8 decimalUnits,
                        string tokenSymbol ) public
  {
    totalSupply = initialSupply * 10 ** uint256(decimalUnits);
    balances_[msg.sender] = totalSupply;
    name = tokenName;
    decimals = decimalUnits;
    symbol = tokenSymbol;
    emit Transfer( address(0), msg.sender, totalSupply );
  }

  function() public payable { revert(); } // does not accept money

  // ERC20
  function balanceOf( address owner ) public constant returns (uint) {
    return balances_[owner];
  }

  // ERC20
  //
  // WARNING! When changing the approval amount, first set it back to zero
  // AND wait until the transaction is mined. Only afterwards set the new
  // amount. Otherwise you may be prone to a race condition attack.
  // See: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

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
  function transfer(address to, uint256 value) public
  {
    bytes memory empty; // null
    _transfer( msg.sender, to, value, empty );
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

  // Ethereum Token
  function approveAndCall( address spender,
                           uint256 value,
                           bytes context ) public
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