contract ITTInterface
{

    using LibCLLu for LibCLLu.CLL;

/* Constants */

    string constant VERSION = "ITT 0.3.6\nERC20 0.2.3-o0ragman0o\nMath 0.0.1\nBase 0.1.1\n";
    uint constant HEAD = 0;
    uint constant MINNUM = uint(1);
    // use only 128 bits of uint to prevent mul overflows.
    uint constant MAXNUM = 2**128;
    uint constant MINPRICE = uint(1);
    uint constant NEG = uint(-1); //2**256 - 1
    bool constant PREV = false;
    bool constant NEXT = true;
    bool constant BID = false;
    bool constant ASK = true;

    // minimum gas required to prevent out of gas on 'take' loop
    uint constant MINGAS = 100000;

    // For staging and commiting trade details.  This saves unneccessary state
    // change gas usage during multi order takes but does increase logic
    // complexity when encountering 'trade with self' orders
    struct TradeMessage {
        bool make;
        bool side;
        uint price;
        uint tradeAmount;
        uint balance;
        uint etherBalance;
    }

/* State Valiables */

    // To allow for trade halting by owner.
    bool public trading;

    // Mapping for ether ownership of accumulated deposits, sales and refunds.
    mapping (address => uint) etherBalance;

    // Orders are stored in circular linked list FIFO's which are mappings with
    // price as key and value as trader address.  A trader can have only one
    // order open at each price. Reordering at that price will cancel the first
    // order and push the new one onto the back of the queue.
    mapping (uint => LibCLLu.CLL) orderFIFOs;
    
    // Order amounts are stored in a seperate lookup. The keys of this mapping
    // are `sha3` hashes of the price and trader address.
    // This mapping prevents more than one order at a particular price.
    mapping (bytes32 => uint) amounts;

    // The pricebook is a linked list holding keys to lookup the price FIFO's
    LibCLLu.CLL priceBook = orderFIFOs[0];


/* Events */

    // Triggered on a make sell order
    event Ask (uint indexed price, uint amount, address indexed trader);

    // Triggered on a make buy order
    event Bid (uint indexed price, uint amount, address indexed trader);

    // Triggered on a filled order
    event Sale (uint indexed price, uint amount, address indexed buyer, address indexed seller);

    // Triggered when trading is started or halted
    event Trading(bool trading);

/* Functions Public constant */

    /// @notice Returns best bid or ask price. 
    function spread(bool _side) public constant returns(uint);
    
    /// @notice Returns the order amount for trader `_trader` at '_price'
    /// @param _trader Address of trader
    /// @param _price Price of order
    function getAmount(uint _price, address _trader) 
        public constant returns(uint);

    /// @notice Returns the collective order volume at a `_price`.
    /// @param _price FIFO for price.
    function getPriceVolume(uint _price) public constant returns (uint);

    /// @notice Returns an array of all prices and their volumes.
    /// @dev [even] indecies are the price. [odd] are the volume. [0] is the
    /// index of the spread.
    function getBook() public constant returns (uint[]);

/* Functions Public non-constant*/

    /// @notice Will buy `_amount` tokens at or below `_price` each.
    /// @param _bidPrice Highest price to bid.
    /// @param _amount The requested amount of tokens to buy.
    /// @param _make Value of true will make order if not filled.
    function buy (uint _bidPrice, uint _amount, bool _make)
        payable returns (bool);

    /// @notice Will sell `_amount` tokens at or above `_price` each.
    /// @param _askPrice Lowest price to ask.
    /// @param _amount The requested amount of tokens to buy.
    /// @param _make A value of true will make an order if not market filled.
    function sell (uint _askPrice, uint _amount, bool _make)
        external returns (bool);

    /// @notice Will withdraw `_ether` to your account.
    /// @param _ether The amount to withdraw
    function withdraw(uint _ether)
        external returns (bool success_);

    /// @notice Cancel order at `_price`
    /// @param _price The price at which the order was placed.
    function cancel(uint _price) 
        external returns (bool);

    /// @notice Will set trading state to `_trading`
    /// @param _trading State to set trading to.
    function setTrading(bool _trading) 
        external returns (bool);
}


/* Intrinsically Tradable Token code */ 

