contract ERC20Interface
{
/* Structs */

/* Constants */
    string constant VERSION = "ERC20 0.2.3-o0ragman0o\nMath 0.0.1\nBase 0.1.1\n";

/* State Valiables */
    uint public totalSupply;
    uint8 public decimalPlaces;
    string public name;
    string public symbol;
    
    // Token ownership mapping
    // mapping (address => uint) public balanceOf;
    mapping (address => uint) balance;
    
    // Transfer allowances mapping
    mapping (address => mapping (address => uint)) public allowance;

/* Events */
    // Triggered when tokens are transferred.
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value);

    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value);

/* Modifiers */

/* Function Abstracts */

    /* State variable Accessor Functions (for reference - leave commented) */

    // Returns the allowable transfer of tokens by a proxy
    // function allowance (address tokenHolders, address proxy, uint allowance) public constant returns (uint);

    // Get the total token supply
    // function totalSupply() public constant returns (uint);

    // Returns token symbol
    // function symbol() public constant returns(string);

    // Returns token symbol
    // function name() public constant returns(string);

    // Returns decimal places designated for unit of token.
    // function decimalPlaces() public returns(uint);

    // Send _value amount of tokens to address _to
    // function transfer(address _to, uint256 _value) public returns (bool success);

    // Send _value amount of tokens from address _from to address _to
    // function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount.
    // function approve(address _spender, uint256 _value) public returns (bool success);
}

