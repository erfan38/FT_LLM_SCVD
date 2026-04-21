contract MultiSigTokenWallet {

    address[] public owners;
    address[] public tokens;
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    uint public transactionCount;
    
    mapping (address => uint) public tokenBalances;
    mapping (address => bool) public isOwner;
    mapping (address => address[]) public userList;
    uint public required;
    uint public nonce;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed _sender, uint indexed _transactionId);
    event Revocation(address indexed _sender, uint indexed _transactionId);
    event Submission(uint indexed _transactionId);
    event Execution(uint indexed _transactionId);
    event ExecutionFailure(uint indexed _transactionId);
    event Deposit(address indexed _sender, uint _value);
    event TokenDeposit(address _token, address indexed _sender, uint _value);
    event OwnerAddition(address indexed _owner);
    event OwnerRemoval(address indexed _owner);
    event RequirementChange(uint _required);
    
    modifier onlyWallet() {
        require (msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require (!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require (isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require (transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require (confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require (!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require (_address != 0);
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        require (ownerCount <= MAX_OWNER_COUNT && _required <= ownerCount && _required != 0 && ownerCount != 0);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /**
    * Public functions
    * 
    **/
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    function constructor(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        require(owners.length == 0 && required == 0);
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    /**
    * @notice deposit a ERC20 token. The amount of deposit is the allowance set to this contract.
    * @param _token the token 