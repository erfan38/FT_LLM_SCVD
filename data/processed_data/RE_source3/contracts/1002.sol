contract BouleICO is Ownable{

    uint public startTime;             // unix ts in which the sale starts.
    uint public secondPriceTime;       // unix ts in which the second price triggers.
    uint public thirdPriceTime;        // unix ts in which the third price starts.
    uint public fourthPriceTime;       // unix ts in which the fourth price starts.
    uint public endTime;               // unix ts in which the sale end.

    address public bouleDevMultisig;   // The address to hold the funds donated

    uint public totalCollected = 0;    // In wei
    bool public saleStopped = false;   // Has Boulé stopped the sale?
    bool public saleFinalized = false; // Has Boulé finalized the sale?

    BouleToken public token;           // The token

    MultiSigWallet wallet;             // Multisig

    uint constant public minInvestment = 0.1 ether;    // Minimum investment  0.1 ETH

    /** Addresses that are allowed to invest even before ICO opens. For testing, for ICO partners, etc. */
    mapping (address => bool) public whitelist;

    event NewBuyer(address indexed holder, uint256 bouAmount, uint256 amount);
    event Whitelisted(address addr, bool status);

    function BouleICO (
    address _token,
    address _bouleDevMultisig,
    uint _startTime,
    uint _secondPriceTime,
    uint _thirdPriceTime,
    uint _fourthPriceTime,
    uint _endTime
    )
    {
        if (_startTime >= _endTime) throw;

        // Save constructor arguments as global variables
        token = BouleToken(_token);
        bouleDevMultisig = _bouleDevMultisig;
        // create wallet object
        wallet = MultiSigWallet(bouleDevMultisig);

        startTime = _startTime;
        secondPriceTime = _secondPriceTime;
        thirdPriceTime = _thirdPriceTime;
        fourthPriceTime = _fourthPriceTime;
        endTime = _endTime;
    }

    // change whitelist status for a specific address
    function setWhitelistStatus(address addr, bool status)
    onlyOwner {
        whitelist[addr] = status;
        Whitelisted(addr, status);
    }

    // @notice Get the price for a BOU token at current time (how many tokens for 1 ETH)
    // @return price of BOU
    function getPrice() constant public returns (uint256) {
        var time = getNow();
        if(time < startTime){
            // whitelist
            return 1400;
        }
        if(time < secondPriceTime){
            return 1200; //20%
        }
        if(time < thirdPriceTime){
            return 1150; //15%
        }
        if(time < fourthPriceTime){
            return 1100; //10%
        }
        return 1050; //5%
    }


    /**
        * Get the amount of unsold tokens allocated to this contract;
    */
    function getTokensLeft() public constant returns (uint) {
        return token.balanceOf(this);
    }


    /// The fallback function is called when ether is sent to the contract, it
    /// simply calls `doPayment()` with the address that sent the ether as the
    /// `_owner`. Payable is a required solidity modifier for functions to receive
    /// ether, without this modifier functions will throw if ether is sent to them

    function () public payable {
        doPayment(msg.sender);
    }



    /// @dev `doPayment()` is an internal function that sends the ether that this
    ///  