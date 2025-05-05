contract ArtifactCoin is ERC223  {
    
    using SafeMath for uint256;
    using SafeMath for uint;
    address public owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public blacklist;
    mapping (address => uint256) public unlockUnixTime;
    string internal name_= "ArtifactCoin";
    string public Information= "アーティファクトチェーン";
    string internal symbol_ = "3A";
    uint8 internal decimals_= 18;
    bool public canTransfer = true;
    uint256 public etherGetBase=6000000;
    uint256 internal totalSupply_= 2000000000e18;
    uint256 public OfficalHolding = totalSupply_.mul(30).div(100);
    uint256 public totalRemaining = totalSupply_;
    uint256 public totalDistributed = 0;
    uint256 internal freeGiveBase = 300e17;
    uint256 public lowEth = 1e14;
    bool public distributionFinished = false;
    bool public endFreeGet = false;
    bool public endEthGet = false;    
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier canTrans() {
        require(canTransfer == true);
        _;
    }    
    modifier onlyWhitelist() {
        require(blacklist[msg.sender] == false);
        _;
    }
    
    function ArtifactCoin (address offical) public {
        owner = msg.sender;
        distr(offical, OfficalHolding);
    }

    // Function to access name of token .
    function name() public view returns (string _name) {
      return name_;
    }
    // Function to access symbol of token .
    function symbol() public view returns (string _symbol) {
      return symbol_;
    }
    // Function to access decimals of token .
    function decimals() public view returns (uint8 _decimals) {
      return decimals_;
    }
    // Function to access total supply of tokens .
    function totalSupply() public view returns (uint256 _totalSupply) {
      return totalSupply_;
    }


    // Function that is called when a user or another 