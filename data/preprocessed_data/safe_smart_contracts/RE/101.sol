contract Nomin is FeeToken {

    /* ========== STATE VARIABLES ========== */

    Havven public havven;

    // Accounts which have lost the privilege to transact in nomins.
    mapping(address => bool) public frozen;

    // Nomin transfers incur a 15 bp fee by default.
    uint constant TRANSFER_FEE_RATE = 15 * UNIT / 10000;
    string constant TOKEN_NAME = "Nomin USD";
    string constant TOKEN_SYMBOL = "nUSD";

    /* ========== CONSTRUCTOR ========== */

    constructor(address _proxy, TokenState _tokenState, Havven _havven,
                uint _totalSupply,
                address _owner)
        FeeToken(_proxy, _tokenState,
                 TOKEN_NAME, TOKEN_SYMBOL, _totalSupply,
                 TRANSFER_FEE_RATE,
                 _havven, // The havven 