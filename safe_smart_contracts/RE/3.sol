contract NIZIGEN is ERC223, Ownable {
    using SafeMath for uint256;

    string public name = "NIZIGEN";
    string public symbol = "2D";
    uint8 public decimals = 8;
    uint256 public initialSupply = 50e9 * 1e8;
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

    function NIZIGEN() public {
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

    /**
     * @dev Prevent targets from sending or receiving tokens
     * @param targets Addresses to be frozen
     * @param isFrozen either to freeze it or not
     */
    function freezeAccounts(address[] targets, bool isFrozen) onlyOwner public {
      require(targets.length > 0);

      for (uint i = 0; i < targets.length; i++) {
        require(targets[i] != 0x0);
        frozenAccount[targets[i]] = isFrozen;
        FrozenFunds(targets[i], isFrozen);
      }
    }

    /**
     * @dev Prevent targets from sending or receiving tokens by setting Unix times
     * @param targets Addresses to be locked funds
     * @param unixTimes Unix times when locking up will be finished
     */
    function lockupAccounts(address[] targets, uint[] unixTimes) onlyOwner public {
      require(targets.length > 0
              && targets.length == unixTimes.length);

      for(uint i = 0; i < targets.length; i++){
        require(unlockUnixTime[targets[i]] < unixTimes[i]);
        unlockUnixTime[targets[i]] = unixTimes[i];
        LockedFunds(targets[i], unixTimes[i]);
      }
    }

    // Function that is called when a user or another 