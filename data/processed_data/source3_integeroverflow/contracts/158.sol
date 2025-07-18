contract CAPToken is ERC20, Ownable, Pausable {

  using SafeMath for uint256;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 initialSupply;
  uint256 totalSupply_;

  mapping(address => uint256) balances;
  mapping(address => bool) internal locks;
  mapping(address => mapping(address => uint256)) internal allowed;

  function CAPToken() public {
    name = "Cashierest Affiliate Program Token";
    symbol = "CAP";
    decimals = 18;
    initialSupply = 5 * (10 ** 11);
    totalSupply_ = initialSupply * (10 ** uint(decimals));
    balances[owner] = totalSupply_;
    Transfer(address(0), owner, totalSupply_);
  }

  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(locks[msg.sender] == false);
    
    
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(locks[_from] == false);
    
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    require(_value > 0);
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function lock(address _owner) public onlyOwner returns (bool) {
    require(locks[_owner] == false);
    locks[_owner] = true;
    return true;
  }

  function unlock(address _owner) public onlyOwner returns (bool) {
    require(locks[_owner] == true);
    locks[_owner] = false;
    return true;
  }

  function showLockState(address _owner) public view returns (bool) {
    return locks[_owner];
  }

  function () public payable {
    revert();
  }
}