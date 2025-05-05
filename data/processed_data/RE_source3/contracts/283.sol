contract Excalibur is ERC223, Ownable {
  using SafeMath for uint256;

  string public name = "ExcaliburCoin";
  string public symbol = "EXC";
  uint8 public decimals = 8;
  uint256 public initialSupply = 10e11 * 1e8;
  uint256 public totalSupply;
  uint256 public distributeAmount = 0;
  bool public mintingFinished = false;

  mapping (address => uint) balances;
  mapping (address => bool) public frozenAccount;
  mapping (address => uint256) public unlockUnixTime;

  event FrozenFunds(address indexed target, bool frozen);
  event LockedFunds(address indexed target, uint256 locked);
  event Burn(address indexed burner, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  function Excalibur() public {
    totalSupply = initialSupply;
    balances[msg.sender] = totalSupply;
  }

  function name() public view returns (string _name) {
    return name;
  }

  function symbol() public view returns (string _symbol) {
    return symbol;
  }

  function decimals() public view returns (uint8 _decimals) {
    return decimals;
  }

  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  modifier onlyPayloadSize(uint256 size){
    assert(msg.data.length >= size + 4);
    _;
  }

  // Function that is called when a user or another 