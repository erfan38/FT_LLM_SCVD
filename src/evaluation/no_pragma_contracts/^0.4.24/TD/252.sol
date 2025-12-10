contract BlockFollowMainStageCrowdsale is StageCrowdsale, CappedStageCrowdsale, LimitedMinPurchaseCrowdsale,
    ManualTokenDistributionCrowdsale, PausableCrowdsale, RefundableStageCrowdsale, WhitelistedCrowdsale {
    using SafeMath for uint256;

    mapping (address => bool) public claimedBonus;
    uint256 public ratePerEth;

    uint256 public bonusTokensPool;
    uint256 public burnPercentage;
    uint256 public totalTokensSold;
    uint256 purchasableTokenSupply;

    constructor(
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        StageCrowdsale _previousStage,
        uint256 _ratePerEth,
        uint256 _minPurchase,
        uint256 _minCap,
        uint256 _maxCap,
        uint256 _burnPercentage,
        uint256 _purchasableTokenSupply,
        Whitelist _whitelist
    )
        public
        CappedCrowdsale(_maxCap)
        LimitedMinPurchaseCrowdsale(_minPurchase)
        StageCrowdsale(_ratePerEth, _wallet, _token, _openingTime, _openingTime + 4 weeks, _previousStage)
        RefundableCrowdsale(_minCap)
        WhitelistedCrowdsale(_whitelist)
    {
        require(_ratePerEth > 0, "Rate per ETH cannot be null");
        require(_burnPercentage > 0, "Burn percenatage cannot be null");
        require(_purchasableTokenSupply > 0, "Purchasable token supply cannot be null");
        ratePerEth = _ratePerEth;
        burnPercentage = _burnPercentage;
        purchasableTokenSupply = _purchasableTokenSupply;
    }

     
    modifier canClaimBonus() {
        require(isFinalized, "Cannot claim bonus when stage is not yet finalized");
         
        require(now < openingTime + 6 weeks, "Cannot claim bonus tokens too soon");
        require(!claimedBonus[msg.sender], "Cannot claim bonus tokens repeatedly");
        require(totalTokensSold > 0, "Cannot claim bonus tokens when no purchase have been made");
        _;
    }

     
    function claimBonusTokens() public canClaimBonus {
        uint256 senderBalance = token.balanceOf(msg.sender);
        uint256 purchasedProportion = senderBalance.mul(1e18).div(totalTokensSold);
        uint256 bonusForSender = bonusTokensPool.mul(purchasedProportion).div(1e18);
        token.transfer(msg.sender, bonusForSender);
        claimedBonus[msg.sender] = true;
    }

     
    function claimRemainingTokens() public onlyOwner {
        uint256 balance = token.balanceOf(this);
        manualSendTokens(msg.sender, balance);
    }

     
    function finalization() internal {
        super.finalization();

        uint256 balance = token.balanceOf(address(this));
        totalTokensSold = purchasableTokenSupply.sub(balance);

        uint256 balanceToBurn = balance.mul(burnPercentage).div(100);
        BurnableToken(address(token)).burn(balanceToBurn);

        uint256 bonusPercentage = 100 - burnPercentage;
        bonusTokensPool = balance.mul(100).mul(bonusPercentage).div(1e4);
    }


    
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.div(1e10).mul(ratePerEth);
    }
}