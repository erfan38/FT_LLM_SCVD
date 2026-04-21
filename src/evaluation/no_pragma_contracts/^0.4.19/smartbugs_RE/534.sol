contract FeeToken is ExternStateToken {

    /* ========== STATE VARIABLES ========== */

    /* ERC20 members are declared in ExternStateToken. */

    /* A percentage fee charged on each transfer. */
    uint public transferFeeRate;
    /* Fee may not exceed 10%. */
    uint constant MAX_TRANSFER_FEE_RATE = UNIT / 10;
    /* The address with the authority to distribute fees. */
    address public feeAuthority;
    /* The address that fees will be pooled in. */
    address public constant FEE_ADDRESS = 0xfeefeefeefeefeefeefeefeefeefeefeefeefeef;


    /* ========== CONSTRUCTOR ========== */

    /**
     * @dev Constructor.
     * @param _proxy The proxy associated with this contract.
     * @param _name Token's ERC20 name.
     * @param _symbol Token's ERC20 symbol.
     * @param _totalSupply The total supply of the token.
     * @param _transferFeeRate The fee rate to charge on transfers.
     * @param _feeAuthority The address which has the authority to withdraw fees from the accumulated pool.
     * @param _owner The owner of this contract.
     */
    constructor(address _proxy, TokenState _tokenState, string _name, string _symbol, uint _totalSupply,
                uint _transferFeeRate, address _feeAuthority, address _owner)
        ExternStateToken(_proxy, _tokenState,
                         _name, _symbol, _totalSupply,
                         _owner)
        public
    {
        feeAuthority = _feeAuthority;

        /* Constructed transfer fee rate should respect the maximum fee rate. */
        require(_transferFeeRate <= MAX_TRANSFER_FEE_RATE, "Constructed transfer fee rate should respect the maximum fee rate");
        transferFeeRate = _transferFeeRate;
    }

    /* ========== SETTERS ========== */

    /**
     * @notice Set the transfer fee, anywhere within the range 0-10%.
     * @dev The fee rate is in decimal format, with UNIT being the value of 100%.
     */
    function setTransferFeeRate(uint _transferFeeRate)
        external
        optionalProxy_onlyOwner
    {
        require(_transferFeeRate <= MAX_TRANSFER_FEE_RATE, "Transfer fee rate must be below MAX_TRANSFER_FEE_RATE");
        transferFeeRate = _transferFeeRate;
        emitTransferFeeRateUpdated(_transferFeeRate);
    }

    /**
     * @notice Set the address of the user/