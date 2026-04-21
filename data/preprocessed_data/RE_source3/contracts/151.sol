contract ZethrBankroll is ERC223Receiving {
    using SafeMath for uint;

    /*=================================
    =              EVENTS            =
    =================================*/

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event WhiteListAddition(address indexed contractAddress);
    event WhiteListRemoval(address indexed contractAddress);
    event RequirementChange(uint required);
    event DevWithdraw(uint amountTotal, uint amountPerPerson);
    event EtherLogged(uint amountReceived, address sender);
    event BankrollInvest(uint amountReceived);
    event DailyTokenAdmin(address gameContract);
    event DailyTokensSent(address gameContract, uint tokens);
    event DailyTokensReceived(address gameContract, uint tokens);

    /*=================================
    =        WITHDRAWAL CONSTANTS     =
    =================================*/

    uint constant public MAX_OWNER_COUNT = 10;
    uint constant public MAX_WITHDRAW_PCT_DAILY = 15;
    uint constant public MAX_WITHDRAW_PCT_TX = 5;
    uint constant internal resetTimer = 1 days;

    /*=================================
    =          ZTH INTERFACE          =
    =================================*/

    address internal zethrAddress;
    ZTHInterface public ZTHTKN;

    /*=================================
    =             VARIABLES           =
    =================================*/

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    mapping (address => bool) public isWhitelisted;
    mapping (address => uint) public dailyTokensPerContract;
    address internal divCardAddress;
    address[] public owners;
    address[] public whiteListedContracts;
    uint public required;
    uint public transactionCount;
    uint internal dailyResetTime;
    uint internal dailyTknLimit;
    uint internal tknsDispensedToday;
    bool internal reEntered = false;

    /*=================================
    =         CUSTOM CONSTRUCTS       =
    =================================*/

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    struct TKN {
        address sender;
        uint value;
    }

    /*=================================
    =            MODIFIERS            =
    =================================*/

    modifier onlyWallet() {
        if (msg.sender != address(this))
            revert();
        _;
    }

    modifier contractIsNotWhiteListed(address contractAddress) {
        if (isWhitelisted[contractAddress])
            revert();
        _;
    }

    modifier contractIsWhiteListed(address contractAddress) {
        if (!isWhitelisted[contractAddress])
            revert();
        _;
    }

    modifier isAnOwner() {
        address caller = msg.sender;
        if (!isOwner[caller])
            revert();
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner])
            revert();
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner])
            revert();
        _;
    }

    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0)
            revert();
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner])
            revert();
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
            revert();
        _;
    }

    modifier notNull(address _address) {
        if (_address == 0)
            revert();
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (   ownerCount > MAX_OWNER_COUNT
            || _required > ownerCount
            || _required == 0
            || ownerCount == 0)
            revert();
        _;
    }

    /*=================================
    =          LIST OF OWNERS         =
    =================================*/

    /*
        This list is for reference/identification purposes only, and comprises the eight core Zethr developers.
        For game contracts to be listed, they must be approved by a majority (i.e. currently five) of the owners.
        Contracts can be delisted in an emergency by a single owner.

        0x4F4eBF556CFDc21c3424F85ff6572C77c514Fcae // Norsefire
        0x11e52c75998fe2E7928B191bfc5B25937Ca16741 // klob
        0x20C945800de43394F70D789874a4daC9cFA57451 // Etherguy
        0xef764BAC8a438E7E498c2E5fcCf0f174c3E3F8dB // blurr
        0x8537aa2911b193e5B377938A723D805bb0865670 // oguzhanox
        0x9D221b2100CbE5F05a0d2048E2556a6Df6f9a6C3 // Randall
        0x71009e9E4e5e68e77ECc7ef2f2E95cbD98c6E696 // cryptodude
        0xDa83156106c4dba7A26E9bF2Ca91E273350aa551 // TropicalRogue
    */


    /*=================================
    =         PUBLIC FUNCTIONS        =
    =================================*/

    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    constructor (address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0)
                revert();
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;

        dailyResetTime = now - (1 days);
    }

    /** Testing only.
    function exitAll()
        public
    {
        uint tokenBalance = ZTHTKN.balanceOf(address(this));
        ZTHTKN.sell(tokenBalance - 1e18);
        ZTHTKN.sell(1e18);
        ZTHTKN.withdraw(address(0x0));
    }
    **/

    function addZethrAddresses(address _zethr, address _divcards)
        public
        isAnOwner
    {
        zethrAddress   = _zethr;
        divCardAddress = _divcards;
        ZTHTKN = ZTHInterface(zethrAddress);
    }

    /// @dev Fallback function allows Ether to be deposited.
    function()
        public
        payable
    {

    }

    uint NonICOBuyins;

    function deposit()
        public
        payable
    {
        NonICOBuyins = NonICOBuyins.add(msg.value);
    }

    /// @dev Function to buy tokens with 