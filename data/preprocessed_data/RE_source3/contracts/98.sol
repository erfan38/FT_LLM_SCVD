contract HavvenEscrow is SafeDecimalMath, Owned, LimitedSetup(8 weeks) {
    /* The corresponding Havven contract. */
    Havven public havven;

    /* Lists of (timestamp, quantity) pairs per account, sorted in ascending time order.
     * These are the times at which each given quantity of havvens vests. */
    mapping(address => uint[2][]) public vestingSchedules;

    /* An account's total vested havven balance to save recomputing this for fee extraction purposes. */
    mapping(address => uint) public totalVestedAccountBalance;

    /* The total remaining vested balance, for verifying the actual havven balance of this 