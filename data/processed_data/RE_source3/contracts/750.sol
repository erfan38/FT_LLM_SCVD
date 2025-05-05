contract Gifto is ERC20Interface {
    uint public constant decimals = 5;

    string public constant symbol = "Gifto";
    string public constant name = "Gifto";

    bool public _selling = false;//initial not selling
    uint public _totalSupply = 10 ** 14; // total supply is 10^14 unit, equivalent to 10^9 Gifto
    uint public _originalBuyPrice = 10 ** 10; // original buy in wei of one unit. Ajustable.

    // Owner of this 