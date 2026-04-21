contract Havven is ExternStateToken {

    /* ========== STATE VARIABLES ========== */

    /* A struct for handing values associated with average balance calculations */
    struct IssuanceData {
        /* Sums of balances*duration in the current fee period.
        /* range: decimals; units: havven-seconds */
        uint currentBalanceSum;
        /* The last period's average balance */
        uint lastAverageBalance;
        /* The last time the data was calculated */
        uint lastModified;
    }

    /* Issued nomin balances for individual fee entitlements */
    mapping(address => IssuanceData) public issuanceData;
    /* The total number of issued nomins for determining fee entitlements */
    IssuanceData public totalIssuanceData;

    /* The time the current fee period began */
    uint public feePeriodStartTime;
    /* The time the last fee period began */
    uint public lastFeePeriodStartTime;

    /* Fee periods will roll over in no shorter a time than this. 
     * The fee period cannot actually roll over until a fee-relevant
     * operation such as withdrawal or a fee period duration update occurs,
     * so this is just a target, and the actual duration may be slightly longer. */
    uint public feePeriodDuration = 4 weeks;
    /* ...and must target between 1 day and six months. */
    uint constant MIN_FEE_PERIOD_DURATION = 1 days;
    uint constant MAX_FEE_PERIOD_DURATION = 26 weeks;

    /* The quantity of nomins that were in the fee pot at the time */
    /* of the last fee rollover, at feePeriodStartTime. */
    uint public lastFeesCollected;

    /* Whether a user has withdrawn their last fees */
    mapping(address => bool) public hasWithdrawnFees;

    Nomin public nomin;
    HavvenEscrow public escrow;

    /* The address of the oracle which pushes the havven price to this contract */
    address public oracle;
    /* The price of havvens written in UNIT */
    uint public price;
    /* The time the havven price was last updated */
    uint public lastPriceUpdateTime;
    /* How long will the 