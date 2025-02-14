pragma solidity 0.5.2;




interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract KyberDxMarketMaker is Withdrawable {
    
    ERC20 constant internal KYBER_ETH_TOKEN = ERC20(
        0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    );

    
    uint public constant DX_AUCTION_START_WAITING_FOR_FUNDING = 1;

    enum AuctionState {
        WAITING_FOR_FUNDING,
        WAITING_FOR_OPP_FUNDING,
        WAITING_FOR_SCHEDULED_AUCTION,
        AUCTION_IN_PROGRESS,
        WAITING_FOR_OPP_TO_FINISH,
        AUCTION_EXPIRED
    }

    
    AuctionState constant public WAITING_FOR_FUNDING = AuctionState.WAITING_FOR_FUNDING;
    AuctionState constant public WAITING_FOR_OPP_FUNDING = AuctionState.WAITING_FOR_OPP_FUNDING;
    AuctionState constant public WAITING_FOR_SCHEDULED_AUCTION = AuctionState.WAITING_FOR_SCHEDULED_AUCTION;
    AuctionState constant public AUCTION_IN_PROGRESS = AuctionState.AUCTION_IN_PROGRESS;
    AuctionState constant public WAITING_FOR_OPP_TO_FINISH = AuctionState.WAITING_FOR_OPP_TO_FINISH;
    AuctionState constant public AUCTION_EXPIRED = AuctionState.AUCTION_EXPIRED;

    DutchExchange public dx;
    EtherToken public weth;
    KyberNetworkProxy public kyberNetworkProxy;

    
    mapping (address => mapping (address => uint)) public lastParticipatedAuction;

    constructor(
        DutchExchange _dx,
        KyberNetworkProxy _kyberNetworkProxy
    ) public {
        require(
            address(_dx) != address(0),
            "DutchExchange address cannot be 0"
        );
        require(
            address(_kyberNetworkProxy) != address(0),
            "KyberNetworkProxy address cannot be 0"
        );

        dx = DutchExchange(_dx);
        weth = EtherToken(dx.ethToken());
        kyberNetworkProxy = KyberNetworkProxy(_kyberNetworkProxy);
    }

    event KyberNetworkProxyUpdated(
        KyberNetworkProxy kyberNetworkProxy
    );

    function setKyberNetworkProxy(
        KyberNetworkProxy _kyberNetworkProxy
    )
        public
        onlyAdmin
        returns (bool)
    {
        require(
            address(_kyberNetworkProxy) != address(0),
            "KyberNetworkProxy address cannot be 0"
        );

        kyberNetworkProxy = _kyberNetworkProxy;
        emit KyberNetworkProxyUpdated(kyberNetworkProxy);
        return true;
    }

    event AmountDepositedToDx(
        address indexed token,
        uint amount
    );

    function depositToDx(
        address token,
        uint amount
    )
        public
        onlyOperator
        returns (uint)
    {
        require(ERC20(token).approve(address(dx), amount), "Cannot approve deposit");
        uint deposited = dx.deposit(token, amount);
        emit AmountDepositedToDx(token, deposited);
        return deposited;
    }

    event AmountWithdrawnFromDx(
        address indexed token,
        uint amount
    );

    function withdrawFromDx(
        address token,
        uint amount
    )
        public
        onlyOperator
        returns (uint)
    {
        uint withdrawn = dx.withdraw(token, amount);
        emit AmountWithdrawnFromDx(token, withdrawn);
        return withdrawn;
    }

    





    function claimSpecificAuctionFunds(
        address sellToken,
        address buyToken,
        uint auctionIndex
    )
        public
        returns (uint sellerFunds, uint buyerFunds)
    {
        uint availableFunds;
        availableFunds = dx.sellerBalances(
            sellToken,
            buyToken,
            auctionIndex,
            address(this)
        );
        if (availableFunds > 0) {
            (sellerFunds, ) = dx.claimSellerFunds(
                sellToken,
                buyToken,
                address(this),
                auctionIndex
            );
        }

        availableFunds = dx.buyerBalances(
            sellToken,
            buyToken,
            auctionIndex,
            address(this)
        );
        if (availableFunds > 0) {
            (buyerFunds, ) = dx.claimBuyerFunds(
                sellToken,
                buyToken,
                address(this),
                auctionIndex
            );
        }
    }

    






    
    function step(
        address sellToken,
        address buyToken
    )
        public
        onlyOperator
        returns (bool)
    {
        
        
        
        
        
        require(
            ERC20(sellToken).decimals() == 18 && ERC20(buyToken).decimals() == 18,
            "Only 18 decimals tokens are supported"
        );

        
        depositAllBalance(sellToken);
        depositAllBalance(buyToken);

        AuctionState state = getAuctionState(sellToken, buyToken);
        uint auctionIndex = dx.getAuctionIndex(sellToken, buyToken);
        emit CurrentAuctionState(sellToken, buyToken, auctionIndex, state);

        if (state == AuctionState.WAITING_FOR_FUNDING) {
            
            claimSpecificAuctionFunds(
                sellToken,
                buyToken,
                lastParticipatedAuction[sellToken][buyToken]
            );
            require(fundAuctionDirection(sellToken, buyToken));
            return true;
        }

        if (state == AuctionState.WAITING_FOR_OPP_FUNDING ||
            state == AuctionState.WAITING_FOR_SCHEDULED_AUCTION) {
            return false;
        }

        if (state == AuctionState.AUCTION_IN_PROGRESS) {
            if (isPriceRightForBuying(sellToken, buyToken, auctionIndex)) {
                return buyInAuction(sellToken, buyToken);
            }
            return false;
        }

        if (state == AuctionState.WAITING_FOR_OPP_TO_FINISH) {
            return false;
        }

        if (state == AuctionState.AUCTION_EXPIRED) {
            dx.closeTheoreticalClosedAuction(sellToken, buyToken, auctionIndex);
            dx.closeTheoreticalClosedAuction(buyToken, sellToken, auctionIndex);
            return true;
        }

        
        revert("Unknown auction state");
    }

    function willAmountClearAuction(
        address sellToken,
        address buyToken,
        uint auctionIndex,
        uint amount
    )
        public
        view
        returns (bool)
    {
        uint buyVolume = dx.buyVolumes(sellToken, buyToken);

        
        
        
        uint sellVolume = dx.sellVolumesCurrent(sellToken, buyToken);

        uint num;
        uint den;
        (num, den) = dx.getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);
        
        uint outstandingVolume = atleastZero(int(div(mul(sellVolume, num), sub(den, buyVolume))));
        return amount >= outstandingVolume;
    }

    
    function thresholdNewAuctionToken(
        address token
    )
        public
        view
        returns (uint)
    {
        uint priceTokenNum;
        uint priceTokenDen;
        (priceTokenNum, priceTokenDen) = dx.getPriceOfTokenInLastAuction(token);

        
        
        return 1 + div(
            
            mul(
                dx.thresholdNewAuction(),
                priceTokenDen
            ),
            mul(
                dx.ethUSDOracle().getUSDETHPrice(),
                priceTokenNum
            )
        );
    }

    function calculateMissingTokenForAuctionStart(
        address sellToken,
        address buyToken
    )
        public
        view
        returns (uint)
    {
        uint currentAuctionSellVolume = dx.sellVolumesCurrent(sellToken, buyToken);
        uint thresholdTokenWei = thresholdNewAuctionToken(sellToken);

        if (thresholdTokenWei > currentAuctionSellVolume) {
            return sub(thresholdTokenWei, currentAuctionSellVolume);
        }

        return 0;
    }

    function addFee(
        uint amount
    )
        public
        view
        returns (uint)
    {
        uint num;
        uint den;
        (num, den) = dx.getFeeRatio(msg.sender);

        
        return div(
            mul(amount, den),
            sub(den, num)
        );
    }

    function getAuctionState(
        address sellToken,
        address buyToken
    )
        public
        view
        returns (AuctionState)
    {

        
        uint auctionStart = dx.getAuctionStart(sellToken, buyToken);
        if (auctionStart == DX_AUCTION_START_WAITING_FOR_FUNDING) {
            
            
            if (calculateMissingTokenForAuctionStart(sellToken, buyToken) > 0) {
                return AuctionState.WAITING_FOR_FUNDING;
            } else {
                return AuctionState.WAITING_FOR_OPP_FUNDING;
            }
        }

        
        
        if (auctionStart > now) {
            
            
            
            
            if (calculateMissingTokenForAuctionStart(sellToken, buyToken) > 0) {
                return AuctionState.WAITING_FOR_FUNDING;
            } else {
                return AuctionState.WAITING_FOR_SCHEDULED_AUCTION;
            }
        }

        
        
        
        if (now - auctionStart > 24 hours) {
            return AuctionState.AUCTION_EXPIRED;
        }

        uint auctionIndex = dx.getAuctionIndex(sellToken, buyToken);
        uint closingPriceDen;
        (, closingPriceDen) = dx.closingPrices(sellToken, buyToken, auctionIndex);
        if (closingPriceDen == 0) {
            return AuctionState.AUCTION_IN_PROGRESS;
        }

        return AuctionState.WAITING_FOR_OPP_TO_FINISH;
    }

    function getKyberRate(
        address srcToken,
        address destToken,
        uint amount
    )
        public
        view
        returns (uint num, uint den)
    {
        
        
        
        
        
        require(
            ERC20(srcToken).decimals() == 18 && ERC20(destToken).decimals() == 18,
            "Only 18 decimals tokens are supported"
        );

        
        uint rate;
        (rate, ) = kyberNetworkProxy.getExpectedRate(
            srcToken == address(weth) ? KYBER_ETH_TOKEN : ERC20(srcToken),
            destToken == address(weth) ? KYBER_ETH_TOKEN : ERC20(destToken),
            amount
        );

        return (rate, 10 ** 18);
    }

    function tokensSoldInCurrentAuction(
        address sellToken,
        address buyToken,
        uint auctionIndex,
        address account
    )
        public
        view
        returns (uint)
    {
        return dx.sellerBalances(sellToken, buyToken, auctionIndex, account);
    }

    
    
    function calculateAuctionBuyTokens(
        address sellToken,
        address buyToken,
        uint auctionIndex,
        address account
    )
        public
        view
        returns (uint)
    {
        uint sellVolume = tokensSoldInCurrentAuction(
            sellToken,
            buyToken,
            auctionIndex,
            account
        );

        uint num;
        uint den;
        (num, den) = dx.getCurrentAuctionPrice(
            sellToken,
            buyToken,
            auctionIndex
        );

        
        if (den == 0) return 0;

        uint desiredBuyVolume = div(mul(sellVolume, num), den);

        
        uint auctionSellVolume = dx.sellVolumesCurrent(sellToken, buyToken);
        uint existingBuyVolume = dx.buyVolumes(sellToken, buyToken);
        uint availableBuyVolume = atleastZero(
            int(mul(auctionSellVolume, num) / den - existingBuyVolume)
        );

        return desiredBuyVolume < availableBuyVolume
            ? desiredBuyVolume
            : availableBuyVolume;
    }

    function atleastZero(int a)
        public
        pure
        returns (uint)
    {
        if (a < 0) {
            return 0;
        } else {
            return uint(a);
        }
    }

    event Execution(
        bool success,
        address caller,
        address destination,
        uint value,
        bytes data,
        bytes result
    );

    
    function executeTransaction(
        address destination,
        uint value,
        bytes memory data
    )
        public
        onlyAdmin
    {
        (bool success, bytes memory result) = destination.call.value(value)(data);
        if (success) {
            emit Execution(true, msg.sender, destination, value, data, result);
        } else {
            revert();
        }
    }

    function adminBuyInAuction(
        address sellToken,
        address buyToken
    )
        public
        onlyAdmin
        returns (bool bought)
    {
        return buyInAuction(sellToken, buyToken);
    }

    event AuctionDirectionFunded(
        address indexed sellToken,
        address indexed buyToken,
        uint indexed auctionIndex,
        uint sellTokenAmount,
        uint sellTokenAmountWithFee
    );

    function fundAuctionDirection(
        address sellToken,
        address buyToken
    )
        internal
        returns (bool)
    {
        uint missingTokens = calculateMissingTokenForAuctionStart(
            sellToken,
            buyToken
        );
        uint missingTokensWithFee = addFee(missingTokens);
        if (missingTokensWithFee == 0) return false;

        uint balance = dx.balances(sellToken, address(this));
        require(
            balance >= missingTokensWithFee,
            "Not enough tokens to fund auction direction"
        );

        uint auctionIndex = dx.getAuctionIndex(sellToken, buyToken);
        dx.postSellOrder(sellToken, buyToken, auctionIndex, missingTokensWithFee);
        lastParticipatedAuction[sellToken][buyToken] = auctionIndex;

        emit AuctionDirectionFunded(
            sellToken,
            buyToken,
            auctionIndex,
            missingTokens,
            missingTokensWithFee
        );
        return true;
    }

    
    event BoughtInAuction(
        address indexed sellToken,
        address indexed buyToken,
        uint auctionIndex,
        uint buyTokenAmount,
        bool clearedAuction
    );

    






    function buyInAuction(
        address sellToken,
        address buyToken
    )
        internal
        returns (bool bought)
    {
        require(
            getAuctionState(sellToken, buyToken) == AuctionState.AUCTION_IN_PROGRESS,
            "No auction in progress"
        );

        uint auctionIndex = dx.getAuctionIndex(sellToken, buyToken);
        uint buyTokenAmount = calculateAuctionBuyTokens(
            sellToken,
            buyToken,
            auctionIndex,
            address(this)
        );

        if (buyTokenAmount == 0) {
            return false;
        }

        bool willClearAuction = willAmountClearAuction(
            sellToken,
            buyToken,
            auctionIndex,
            buyTokenAmount
        );
        if (!willClearAuction) {
            buyTokenAmount = addFee(buyTokenAmount);
        }

        require(
            dx.balances(buyToken, address(this)) >= buyTokenAmount,
            "Not enough buy token to buy required amount"
        );

        dx.postBuyOrder(sellToken, buyToken, auctionIndex, buyTokenAmount);
        emit BoughtInAuction(
            sellToken,
            buyToken,
            auctionIndex,
            buyTokenAmount,
            willClearAuction
        );
        return true;
    }

    function depositAllBalance(
        address token
    )
        internal
        returns (uint)
    {
        uint amount;
        uint balance = ERC20(token).balanceOf(address(this));
        if (balance > 0) {
            amount = depositToDx(token, balance);
        }
        return amount;
    }

    event CurrentAuctionState(
        address indexed sellToken,
        address indexed buyToken,
        uint auctionIndex,
        AuctionState auctionState
    );

    event PriceIsRightForBuying(
        address indexed sellToken,
        address indexed buyToken,
        uint auctionIndex,
        uint amount,
        uint dutchExchangePriceNum,
        uint dutchExchangePriceDen,
        uint kyberPriceNum,
        uint kyberPriceDen,
        bool shouldBuy
    );

    function isPriceRightForBuying(
        address sellToken,
        address buyToken,
        uint auctionIndex
    )
        internal
        returns (bool)
    {
        uint amount = calculateAuctionBuyTokens(
            sellToken,
            buyToken,
            auctionIndex,
            address(this)
        );

        uint dNum;
        uint dDen;
        (dNum, dDen) = dx.getCurrentAuctionPrice(
            sellToken,
            buyToken,
            auctionIndex
        );

        
        
        
        
        uint kNum;
        uint kDen;
        (kDen, kNum) = getKyberRate(
            buyToken, 
            sellToken, 
            amount
        );

        
        bool shouldBuy = mul(dNum, kDen) <= mul(kNum, dDen);
        
        emit PriceIsRightForBuying(
            sellToken,
            buyToken,
            auctionIndex,
            amount,
            dNum,
            dDen,
            kNum,
            kDen,
            shouldBuy
        );
        return shouldBuy;
    }

    
    
    


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    



    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0);
        uint256 c = a / b;
        

        return c;
    }

    



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
}