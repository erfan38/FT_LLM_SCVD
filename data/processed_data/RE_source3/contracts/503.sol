contract TelcoinSale {
    using SafeMath for uint256;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event WalletChanged(address indexed previousWallet, address indexed newWallet);
    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 bonusAmount
    );
    event TokenAltPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount,
        uint256 bonusAmount,
        string symbol,
        string transactionId
    );
    event Pause();
    event Unpause();
    event Withdrawal(address indexed wallet, uint256 weiAmount);
    event Extended(uint256 until);
    event Finalized();
    event Refunding();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    event Whitelisted(
        address indexed participant,
        uint256 minWeiAmount,
        uint256 maxWeiAmount,
        uint32 bonusRate
    );
    event CapFlexed(uint32 flex);

    /// The owner of the contract.
    address public owner;

    /// The temporary token we're selling. Sale tokens can be converted
    /// immediately upon successful completion of the sale. Bonus tokens
    /// are on a separate vesting schedule.
    TelcoinSaleToken public saleToken;
    TelcoinSaleToken public bonusToken;

    /// The token we'll convert to after the sale ends.
    Telcoin public telcoin;

    /// The minimum and maximum goals to reach. If the soft cap is not reached
    /// by the end of the sale, the 