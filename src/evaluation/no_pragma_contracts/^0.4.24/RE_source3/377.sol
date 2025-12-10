contract TERATO is ERC20, SafeMath {

    string public name = "TERATO";

    string public symbol = "TERA";

    uint8 public decimals = 8;

    uint256 public totalSupply = 68000000 * 10**8;

    address public owner;


    bool public tokenCreated = false;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    function TERATO() public {

        // Security check in case EVM has future flaw or exploit to call constructor multiple times
        // Ensure token gets created once only
        require(tokenCreated == false);
        tokenCreated = true;

        owner = msg.sender;
        balances[owner] = totalSupply;

        // Final sanity check to ensure owner balance is greater than zero
        require(balances[owner] > 0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    // Function to access name of token .sha
    function name() constant public returns (string _name) {
        return name;
    }
    // Function to access symbol of token .
    function symbol() constant public returns (string _symbol) {
        return symbol;
    }
    // Function to access decimals of token .
    function decimals() constant public returns (uint8 _decimals) {
        return decimals;
    }
    // Function to access total supply of tokens .
    function totalSupply() constant public returns (uint256 _totalSupply) {
        return totalSupply;
    }

    // Function that is called when a user or another 