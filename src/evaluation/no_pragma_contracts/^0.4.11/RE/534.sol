contract Gifto is ERC20Interface {
    uint256 public constant decimals = 5;

    string public constant symbol = "GTO";
    string public constant name = "Gifto";

    bool public _selling = true;//initial selling
    uint256 public _totalSupply = 10 ** 14; // total supply is 10^14 unit, equivalent to 10^9 Gifto
    uint256 public _originalBuyPrice = 43 * 10**7; // original buy 1ETH = 4300 Gifto = 43 * 10**7 unit

    // Owner of this 