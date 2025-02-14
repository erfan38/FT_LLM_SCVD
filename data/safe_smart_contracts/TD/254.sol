contract BlockFollowPreSaleStageCrowdsale is StageCrowdsale, CappedStageCrowdsale, TokensRollStageCrowdsale,
    ManualTokenDistributionCrowdsale, PausableCrowdsale, WhitelistedCrowdsale {

    uint256 public ratePerEth;

    constructor(
        address _wallet,
        ERC20 _token,
        uint256 _openingTime,
        uint256 _ratePerEth,
        uint256 _maxCap,
        Whitelist _whitelist
    )
        public
        CappedCrowdsale(_maxCap)
        StageCrowdsale(_ratePerEth, _wallet, _token, _openingTime, _openingTime + 2 weeks, StageCrowdsale(address(0)))
        WhitelistedCrowdsale(_whitelist)
    {
        require(_ratePerEth > 0, "Rate per ETH cannot be null");
        ratePerEth = _ratePerEth;
    }

    
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return _weiAmount.div(1e10).mul(ratePerEth);
    }
}