contract Crowdsale {
    using SafeMath for uint;

    // The token being sold
    MintableToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint32 public startTime;
    uint32 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint public rate;

    // amount of raised money in wei
    uint public weiRaised;

    /**
     * @dev Amount of already sold tokens.
     */
    uint public soldTokens;

    /**
     * @dev Maximum amount of tokens to mint.
     */
    uint public hardCap;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint value, uint amount);

    function Crowdsale(uint32 _startTime, uint32 _endTime, uint _rate, uint _hardCap, address _wallet, address _token) {
        require(_startTime >= now);
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);
        require(_hardCap > _rate);

        // token = createTokenContract();
        token = MintableToken(_token);

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        hardCap = _hardCap;
        wallet = _wallet;
    }

    // creates the token to be sold.
    // override this method to have crowdsale of a specific mintable token.
    // function createTokenContract() internal returns (MintableToken) {
    //     return new MintableToken();
    // }

    /**
     * @dev this method might be overridden for implementing any sale logic.
     * @return Actual rate.
     */
    function getRate() internal constant returns (uint) {
        return rate;
    }

    // Fallback function can be used to buy tokens
    function() payable {
        buyTokens(msg.sender, msg.value);
    }

    // Low level token purchase function
    function buyTokens(address beneficiary, uint amountWei) internal {
        require(beneficiary != 0x0);

        // Total minted tokens
        uint totalSupply = token.totalSupply();

        // Actual token minting rate (with considering bonuses and discounts)
        uint actualRate = getRate();

        require(validPurchase(amountWei, actualRate, totalSupply));

        // Calculate token amount to be created
        // uint tokens = rate.mul(msg.value).div(1 ether);
        uint tokens = amountWei.mul(actualRate);

        if (msg.value == 0) { // if it is a btc purchase then check existence all tokens (no change)
            require(tokens.add(totalSupply) <= hardCap);
        }

        // Change, if minted token would be less
        uint change = 0;

        // If hard cap reached
        if (tokens.add(totalSupply) > hardCap) {
            // Rest tokens
            uint maxTokens = hardCap.sub(totalSupply);
            uint realAmount = maxTokens.div(actualRate);

            // Rest tokens rounded by actualRate
            tokens = realAmount.mul(actualRate);
            change = amountWei.sub(realAmount);
            amountWei = realAmount;
        }

        // Bonuses
        postBuyTokens(beneficiary, tokens);

        // Update state
        weiRaised = weiRaised.add(amountWei);
        soldTokens = soldTokens.add(tokens);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, amountWei, tokens);

        if (msg.value != 0) {
            if (change != 0) {
                msg.sender.transfer(change);
            }
            forwardFunds(amountWei);
        }
    }

    // Send ether to the fund collection wallet
    // Override to create custom fund forwarding mechanisms
    function forwardFunds(uint amountWei) internal {
        wallet.transfer(amountWei);
    }

    // Trasfer bonuses and adding delayed bonuses
    function postBuyTokens(address _beneficiary, uint _tokens) internal {
    }

    /**
     * @dev Check if the specified purchase is valid.
     * @return true if the transaction can buy tokens
     */
    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = _amountWei != 0;
        bool hardCapNotReached = _totalSupply <= hardCap.sub(_actualRate);

        return withinPeriod && nonZeroPurchase && hardCapNotReached;
    }

    /**
     * @dev Because of discount hasEnded might be true, but validPurchase returns false.
     * @return true if crowdsale event has ended
     */
    function hasEnded() public constant returns (bool) {
        return now > endTime || token.totalSupply() > hardCap.sub(getRate());
    }

    /**
     * @return true if crowdsale event has started
     */
    function hasStarted() public constant returns (bool) {
        return now >= startTime;
    }
}

/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowsdale where an owner can do extra work
 * after finishing. 
 */
