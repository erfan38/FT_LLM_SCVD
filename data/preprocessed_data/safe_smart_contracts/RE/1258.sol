contract DatCoin is ERC20Interface {
    uint8 public constant decimals = 5;
    string public constant symbol = "DTC";
    string public constant name = "DatCoin";

    uint public _totalSupply = 10 ** 14;
    uint public _originalBuyPrice = 10 ** 10;
    uint public _minimumBuyAmount = 10 ** 17;
    uint public _thresholdOne = 9 * (10 ** 13);
    uint public _thresholdTwo = 85 * (10 ** 12);
   
    // Owner of this 