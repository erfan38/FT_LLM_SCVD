contract NewDecentBetToken is ERC20, SafeMath {

    // Token information
    bool public isDecentBetToken;

    string public constant name = "Decent.Bet Token";

    string public constant symbol = "DBET";

    uint256 public constant decimals = 18;  // decimal places

    uint256 public constant housePercentOfTotal = 10;

    uint256 public constant vaultPercentOfTotal = 18;

    uint256 public constant bountyPercentOfTotal = 2;

    uint256 public constant crowdfundPercentOfTotal = 70;

    // flag to determine if address is for a real 