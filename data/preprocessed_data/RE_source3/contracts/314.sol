contract ShittyToken is Ownable, MintableToken, ERC827Token {

    using SafeMath for *;

    string public constant NAME = "Shitty Token"; // solium-disable-line uppercase
    string public constant SYMBOL = "SHIT"; // solium-disable-line uppercase
    uint8 public constant DECIMALS = 18; // solium-disable-line uppercase
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(DECIMALS));

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    function TokenUnionToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
    
}