contract ExternStateToken is SafeDecimalMath, SelfDestructible, Proxyable, ReentrancyPreventer {

    /* ========== STATE VARIABLES ========== */

    /* Stores balances and allowances. */
    TokenState public tokenState;

    /* Other ERC20 fields.
     * Note that the decimals field is defined in SafeDecimalMath.*/
    string public name;
    string public symbol;
    uint public totalSupply;

    /**
     * @dev Constructor.
     * @param _proxy The proxy associated with this contract.
     * @param _name Token's ERC20 name.
     * @param _symbol Token's ERC20 symbol.
     * @param _totalSupply The total supply of the token.
     * @param _tokenState The TokenState 