contract MCDMonitorV2 is DSMath, AdminAuth, GasBurner, StaticV2 {

    uint public REPAY_GAS_TOKEN = 25;
    uint public BOOST_GAS_TOKEN = 25;

    uint public MAX_GAS_PRICE = 800000000000; // 800 gwei

    uint public REPAY_GAS_COST = 1000000;
    uint public BOOST_GAS_COST = 1000000;

    bytes4 public REPAY_SELECTOR = 0xf360ce20;
    bytes4 public BOOST_SELECTOR = 0x8ec2ae25;

    MCDMonitorProxyV2 public monitorProxyContract;
    ISubscriptionsV2 public subscriptionsContract;
    address public mcdSaverTakerAddress;

    address public constant BOT_REGISTRY_ADDRESS = 0x637726f8b08a7ABE3aE3aCaB01A80E2d8ddeF77B;

    address public constant PROXY_PERMISSION_ADDR = 0x5a4f877CA808Cca3cB7c2A194F80Ab8588FAE26B;

    Manager public manager = Manager(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);
    Vat public vat = Vat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
    Spotter public spotter = Spotter(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);

    DefisaverLogger public constant logger = DefisaverLogger(0x5c55B921f590a89C1Ebe84dF170E655a82b62126);

    modifier onlyApproved() {
        require(BotRegistry(BOT_REGISTRY_ADDRESS).botList(msg.sender), "Not auth bot");
        _;
    }

    constructor(address _monitorProxy, address _subscriptions, address _mcdSaverTakerAddress) public {
        monitorProxyContract = MCDMonitorProxyV2(_monitorProxy);
        subscriptionsContract = ISubscriptionsV2(_subscriptions);
        mcdSaverTakerAddress = _mcdSaverTakerAddress;
    }

    /// @notice Bots call this method to repay for user when conditions are met
    /// @dev If the 