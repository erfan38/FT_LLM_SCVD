contract ESportsBonusProvider is ESportsConstants, Ownable {
    // 1) 10% on your investment during first week
    // 2) 10% to all investors during ICO ( not presale) if we reach 5 000 000 euro investments

    using SafeMath for uint;

    ESportsToken public token;
    address public returnAddressBonuses;
    mapping (address => uint256) investorBonuses;

    uint constant FIRST_WEEK = 7 days;
    uint constant BONUS_THRESHOLD_ETR = 20000 * RATE * TOKEN_DECIMAL_MULTIPLIER; // 5 000 000 EUR -> 20 000 ETH -> ETR

    function ESportsBonusProvider(ESportsToken _token, address _returnAddressBonuses) {
        token = _token;
        returnAddressBonuses = _returnAddressBonuses;
    }

    function getBonusAmount(
        address _buyer,
        uint _totalSold,
        uint _amountTokens,
        uint32 _startTime
    ) onlyOwner public constant returns (uint) {
        uint bonus = 0;
        
        // Apply bonus for amount
        if (now < _startTime + FIRST_WEEK && now >= _startTime) {
            bonus = bonus.add(_amountTokens.div(10)); // 1
        }

        return bonus;
    }

    function addDelayedBonus(
        address _buyer,
        uint _totalSold,
        uint _amountTokens
    ) onlyOwner public returns (uint) {
        uint bonus = 0;

        if (_totalSold < BONUS_THRESHOLD_ETR) {
            uint amountThresholdBonus = _amountTokens.div(10); // 2
            investorBonuses[_buyer] = investorBonuses[_buyer].add(amountThresholdBonus); 
            bonus = bonus.add(amountThresholdBonus);
        }

        return bonus;
    }

    function releaseBonus(address _buyer, uint _totalSold) onlyOwner public returns (uint) {
        require(_totalSold >= BONUS_THRESHOLD_ETR);
        require(investorBonuses[_buyer] > 0);

        uint amountBonusTokens = investorBonuses[_buyer];
        investorBonuses[_buyer] = 0;
        require(token.transfer(_buyer, amountBonusTokens));

        return amountBonusTokens;
    }

    function getDelayedBonusAmount(address _buyer) public constant returns(uint) {
        return investorBonuses[_buyer];
    }

    function sendBonus(address _buyer, uint _amountBonusTokens) onlyOwner public {
        require(token.transfer(_buyer, _amountBonusTokens));
    }

    function releaseThisBonuses() onlyOwner public {
        uint remainBonusTokens = token.balanceOf(this); // send all remaining bonuses
        require(token.transfer(returnAddressBonuses, remainBonusTokens));
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
