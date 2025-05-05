contract StandardToken is ERC223 {
    using SafeMath for uint;

    //user token balances
    mapping (address => uint) balances;
    //token transer permissions
    mapping (address => mapping (address => uint)) allowed;

    // Function that is called when a user or another 