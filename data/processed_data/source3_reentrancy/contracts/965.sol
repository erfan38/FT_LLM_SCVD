contract EDOGE is ERC223, SafeMath {

    string public name = "eDogecoin";

    string public symbol = "EDOGE";

    uint8 public decimals = 8;

    uint256 public totalSupply = 100000000000 * 10**8;

    address public owner;

    bool public unlocked = false;

    bool public tokenCreated = false;

    mapping(address => uint256) balances;

    mapping(address => mapping (address => uint256)) allowed;

    // Initialize to have owner have 100,000,000,000 EDOGE on 