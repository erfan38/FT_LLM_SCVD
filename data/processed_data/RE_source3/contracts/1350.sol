contract EscrowGoods {

    struct EscrowInfo {

        address buyer;
        uint lockedFunds;
        uint frozenFunds;
        uint64 frozenTime;
        uint16 count;
        bool buyerNo;
        bool sellerNo;
    }

    //enum GoodsStatus
    uint16 constant internal None = 0;
    uint16 constant internal Available = 1;
    uint16 constant internal Canceled = 2;

    //enum EventTypes
    uint16 constant internal Buy = 1;
    uint16 constant internal Accept = 2;
    uint16 constant internal Reject = 3;
    uint16 constant internal Cancel = 4;
    uint16 constant internal Description = 10;
    uint16 constant internal Unlock = 11;
    uint16 constant internal Freeze = 12;
    uint16 constant internal Resolved = 13;

    //data

    uint constant arbitrationPeriod = 30 days;
    uint constant safeGas = 25000;

    //seller/owner of the goods
    address public seller;

    //event counters
    uint public contentCount = 0;
    uint public logsCount = 0;

    //escrow related

    address public arbiter;

    uint public freezePeriod;
    //each lock fee in promilles.
    uint public feePromille;
    //reward in promilles. promille = percent * 10, eg 1,5% reward = 15 rewardPromille
    uint public rewardPromille;

    uint public feeFunds;
    uint public totalEscrows;

    mapping (uint => EscrowInfo) public escrows;

    //goods related

    //status of the goods: see GoodsStatus enum
    uint16 public status;
    //how many for sale
    uint16 public count;

    uint16 public availableCount;
    uint16 public pendingCount;

    //price per item
    uint public price;

    mapping (address => bool) public buyers;

    bool private atomicLock;

    //events

    event LogDebug(string message);
    event LogEvent(uint indexed lockId, string dataInfo, uint indexed version, uint16 eventType, address indexed sender, uint count, uint payment);

    modifier onlyOwner {
        if (msg.sender != seller)
          throw;
        _;
    }

    modifier onlyArbiter {
        if (msg.sender != arbiter)
          throw;
        _;
    }

    //modules

    function EscrowGoods(address _arbiter, uint _freezePeriod, uint _feePromille, uint _rewardPromille,
                          uint16 _count, uint _price) {

        seller = msg.sender;

        // all variables are always initialized to 0, save gas

        //escrow related

        arbiter = _arbiter;
        freezePeriod = _freezePeriod;
        feePromille = _feePromille;
        rewardPromille = _rewardPromille;

        //goods related

        status = Available;
        count = _count;
        price = _price;

        availableCount = count;
    }

    //helpers for events with counter
    function logDebug(string message) internal {
        logsCount++;
        LogDebug(message);
    }

    function logEvent(uint lockId, string dataInfo, uint version, uint16 eventType,
                                address sender, uint count, uint payment) internal {
        contentCount++;
        LogEvent(lockId, dataInfo, version, eventType, sender, count, payment);
    }

    function kill() onlyOwner {

        //do not allow killing 