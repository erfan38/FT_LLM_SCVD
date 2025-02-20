contract TokenERC20 {
    address public owner;
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    using SafeMath for uint256;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);

    /**
     * Constrctor function
     *
     * Initializes 