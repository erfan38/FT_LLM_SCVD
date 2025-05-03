contract DividendToken is BalancingToken, Blocked, Owned {

    using SafeMath for uint256;

	// Event for dividends when somebody takes dividends it will raised.
    event DividendReceived(address indexed dividendReceiver, uint256 dividendValue);

	// mapping for alloweds and amounts.
    mapping (address => mapping (address => uint256)) public allowed;

	// full reward amount for one round.
	// this value is defined by ether amount on DividendToken 