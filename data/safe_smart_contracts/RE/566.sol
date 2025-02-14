contract GTO is ERC20Interface {
    uint8 public constant decimals = 5;

    string public constant symbol = "GTO";
    string public constant name = "GTO";

    bool public _selling = false;//initial not selling
    uint256 public _totalSupply = 10 ** 14; // total supply is 10^14 unit, equivalent to 10^9 GTO
    uint256 public _originalBuyPrice = 45 * 10**7; // original buy 1ETH = 4500 GTO = 45 * 10**7 unit

    // Owner of this 