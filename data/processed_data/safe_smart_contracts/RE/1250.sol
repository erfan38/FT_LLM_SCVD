contract RoseCoin is ERC20Interface {
    uint8 public constant decimals = 5;
    string public constant symbol = "RSC";
    string public constant name = "RoseCoin";

    uint public _level = 0;
    bool public _selling = true;
    uint public _totalSupply = 10 ** 14;
    uint public _originalBuyPrice = 10 ** 10;
    uint public _minimumBuyAmount = 10 ** 17;
   
    // Owner of this 