contract AaveMonitor is AdminAuth, DSMath, AaveSafetyRatio, GasBurner {

    using SafeERC20 for ERC20;

    enum Method { Boost, Repay }

    uint public REPAY_GAS_TOKEN = 20;
    uint public BOOST_GAS_TOKEN = 20;

    uint public MAX_GAS_PRICE = 400000000000; // 400 gwei

    uint public REPAY_GAS_COST = 2000000;
    uint public BOOST_GAS_COST = 2000000;

    address public constant DEFISAVER_LOGGER = 0x5c55B921f590a89C1Ebe84dF170E655a82b62126;

    AaveMonitorProxy public aaveMonitorProxy;
    AaveSubscriptions public subscriptionsContract;
    address public aaveSaverProxy;

    DefisaverLogger public logger = DefisaverLogger(DEFISAVER_LOGGER);

    modifier onlyApproved() {
        require(BotRegistry(BOT_REGISTRY_ADDRESS).botList(msg.sender), "Not auth bot");
        _;
    }

    /// @param _aaveMonitorProxy Proxy contracts that actually is authorized to call DSProxy
    /// @param _subscriptions Subscriptions 