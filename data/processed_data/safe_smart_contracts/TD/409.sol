contract StakingPriceFeed is SimplePriceFeed {

    OperatorStaking public stakingContract;
    AssetInterface public stakingToken;

     

     
     
     
    function StakingPriceFeed(
        address ofRegistrar,
        address ofQuoteAsset,
        address ofSuperFeed
    )
        SimplePriceFeed(ofRegistrar, ofQuoteAsset, ofSuperFeed)
    {
        stakingContract = OperatorStaking(ofSuperFeed);  
        stakingToken = AssetInterface(stakingContract.stakingToken());
    }

     

     
     
    function depositStake(uint amount, bytes data)
        external
        auth
    {
        require(stakingToken.transferFrom(msg.sender, address(this), amount));
        require(stakingToken.approve(stakingContract, amount));
        stakingContract.stake(amount, data);
    }

     
     
    function unstake(uint amount, bytes data) {
        stakingContract.unstake(amount, data);
    }

    function withdrawStake()
        external
        auth
    {
        uint amountToWithdraw = stakingContract.stakeToWithdraw(address(this));
        stakingContract.withdrawStake();
        require(stakingToken.transfer(msg.sender, amountToWithdraw));
    }
}

interface RiskMgmtInterface {

     
     

     
     
     
     
     
     
     
     
    function isMakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (bool);

     
     
     
     
     
     
     
     
    function isTakePermitted(
        uint orderPrice,
        uint referencePrice,
        address sellAsset,
        address buyAsset,
        uint sellQuantity,
        uint buyQuantity
    ) view returns (bool);
}

