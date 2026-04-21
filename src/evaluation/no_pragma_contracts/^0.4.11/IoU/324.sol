contract AgriChainToken is ERC20Interface, Owned {
    
    using SafeMath for uint;

    uint256 constant public MAX_SUPPLY = 1000000000000000000000000000; 

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint256 _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    
    bool public isAllowingTransfers;

    
    mapping (address => bool) public administrators;

    
    modifier allowingTransfers() {
        require(isAllowingTransfers, "Contract currently not allowing transfers.");
        _;
    }

    
    modifier onlyAdmin() {
        require(administrators[msg.sender], "Not 