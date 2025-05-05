contract CompoundMonitor is AdminAuth, DSMath, CompoundSafetyRatio, GasBurner {

    using SafeERC20 for ERC20;

    enum Method { Boost, Repay }

    uint public REPAY_GAS_TOKEN = 20;
    uint public BOOST_GAS_TOKEN = 20;

    uint constant public MAX_GAS_PRICE = 500000000000; // 500 gwei

    uint public REPAY_GAS_COST = 1500000;
    uint public BOOST_GAS_COST = 1000000;

    address public constant GAS_TOKEN_INTERFACE_ADDRESS = 0x0000000000b3F879cb30FE243b4Dfee438691c04;
    address public constant DEFISAVER_LOGGER = 0x5c55B921f590a89C1Ebe84dF170E655a82b62126;
    address public constant BOT_REGISTRY_ADDRESS = 0x637726f8b08a7ABE3aE3aCaB01A80E2d8ddeF77B;

    CompoundMonitorProxy public compoundMonitorProxy;
    CompoundSubscriptions public subscriptionsContract;
    address public compoundFlashLoanTakerAddress;

    DefisaverLogger public logger = DefisaverLogger(DEFISAVER_LOGGER);

    modifier onlyApproved() {
        require(BotRegistry(BOT_REGISTRY_ADDRESS).botList(msg.sender), "Not auth bot");
        _;
    }

    /// @param _compoundMonitorProxy Proxy contracts that actually is authorized to call DSProxy
    /// @param _subscriptions Subscriptions 