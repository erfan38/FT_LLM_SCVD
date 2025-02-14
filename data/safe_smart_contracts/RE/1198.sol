contract ERC223BasicToken is ERC223Basic{
    using SafeMath for uint;

    mapping(address => uint) balances;

    // Function that is called when a user or another 