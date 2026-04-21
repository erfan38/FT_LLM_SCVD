contract BaktInterface
{

/* Structs */

    struct Holder {
        uint8 id;
        address votingFor;
        uint40 offerExpiry;
        uint lastClaimed;
        uint tokenBalance;
        uint etherBalance;
        uint votes;
        uint offerAmount;
        mapping (address => uint) allowances;
    }

    struct TX {
        bool blocked;
        uint40 timeLock;
        address from;
        address to;
        uint value;
        bytes data;
    }


/* Constants */

    // Constant max tokens and max ether to prevent potential multiplication
    // overflows in 10e17 fixed point     
    uint constant MAXTOKENS = 2**128 - 10**18;
    uint constant MAXETHER = 2**128;
    uint constant BLOCKPCNT = 10; // 10% holding required to block TX's
    uint constant TOKENPRICE = 1000000000000000;
    uint8 public constant decimalPlaces = 15;

/* State Valiables */

    // A mutex used for reentry protection
    bool __reMutex;

    // Initialisation fuse. Blows on initialisation and used for entry check;
    bool __initFuse = true;

    // Allows the 