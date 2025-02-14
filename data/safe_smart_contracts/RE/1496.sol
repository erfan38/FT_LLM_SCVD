contract Base
{
/* Constants */

    string constant VERSION = "Base 0.1.1 \n";

/* State Variables */

    bool mutex;
    address public owner;

/* Events */

    event Log(string message);
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

/* Modifiers */

    // To throw call not made by owner
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    // This modifier can be used on functions with external calls to
    // prevent reentry attacks.
    // Constraints:
    //   Protected functions must have only one point of exit.
    //   Protected functions cannot use the `return` keyword
    //   Protected functions return values must be through return parameters.
    modifier preventReentry() {
        if (mutex) throw;
        else mutex = true;
        _;
        delete mutex;
        return;
    }

    // This modifier can be applied to pulic access state mutation functions
    // to protect against reentry if a `mutextProtect` function is already
    // on the call stack.
    modifier noReentry() {
        if (mutex) throw;
        _;
    }

    // Same as noReentry() but intended to be overloaded
    modifier canEnter() {
        if (mutex) throw;
        _;
    }
    
/* Functions */

    function Base() { owner = msg.sender; }

    function version() public constant returns (string) {
        return VERSION;
    }

    function contractBalance() public constant returns(uint) {
        return this.balance;
    }

    // Change the owner of a 