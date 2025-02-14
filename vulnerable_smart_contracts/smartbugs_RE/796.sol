pragma solidity 0.4.18;




interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}




interface KyberReserveInterface {

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool);

    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) public view returns(uint);
}




contract KyberDutchXReserve is KyberReserveInterface, Withdrawable, Utils2 {

    uint public constant BPS = 10000;
    uint public constant DEFAULT_KYBER_FEE_BPS = 25;
    uint public feeBps = DEFAULT_KYBER_FEE_BPS;
    uint public dutchXFeeNum;
    uint public dutchXFeeDen;

    DutchXExchange public dutchX;
    address public kyberNetwork;
    WETH9 public weth;

    mapping(address => bool) listedTokens;

    bool public tradeEnabled;

    


    function KyberDutchXReserve(
        DutchXExchange _dutchX,
        address _admin,
        address _kyberNetwork,
        WETH9 _weth
    )
        public
    {
        require(address(_dutchX) != 0);
        require(_admin != 0);
        require(_kyberNetwork != 0);
        require(_weth != WETH9(0));

        dutchX = _dutchX;
        admin = _admin;
        kyberNetwork = _kyberNetwork;
        weth = _weth;

        weth.approve(dutchX, 2 ** 255);
        setDecimals(ETH_TOKEN_ADDRESS);
        listedTokens[ETH_TOKEN_ADDRESS] = true;
    }

    function() public payable {
        
    }

    struct AuctionData {
        uint index;
        ERC20 srcToken;
        ERC20 dstToken;
        uint num;
        uint den;
    }

    


    function getConversionRate(
        ERC20 src,
        ERC20 dest,
        uint srcQty,
        uint blockNumber
    )
        public
        view
        returns(uint)
    {
        blockNumber;
        if (!tradeEnabled) return 0;
        if (!listedTokens[src] || !listedTokens[dest]) return 0;

        AuctionData memory auctionData;
        auctionData.srcToken = src == ETH_TOKEN_ADDRESS ? ERC20(weth) : src;
        auctionData.dstToken = dest == ETH_TOKEN_ADDRESS ? ERC20(weth) : dest;
        auctionData.index = dutchX.getAuctionIndex(auctionData.dstToken, auctionData.srcToken);
        if (auctionData.index == 0) return 0;

        (auctionData.num, auctionData.den) = dutchX.getCurrentAuctionPrice(
                auctionData.dstToken,
                auctionData.srcToken,
                auctionData.index
            );

        if (!sufficientLiquidity(auctionData.srcToken, srcQty, auctionData.dstToken,
            auctionData.num, auctionData.den)) {
            return 0;
        }

        
        uint actualSrcQty = (src == ETH_TOKEN_ADDRESS) ? srcQty * (BPS - feeBps) / BPS : srcQty;
        require(actualSrcQty * auctionData.den > actualSrcQty);
        uint convertedQty = (actualSrcQty * auctionData.den) / auctionData.num;
        
        convertedQty -= convertedQty * dutchXFeeNum / dutchXFeeDen;

        
        convertedQty = (src == ETH_TOKEN_ADDRESS) ? convertedQty : convertedQty * (BPS - feeBps) / BPS;

        return calcRateFromQty(
            actualSrcQty, 
            convertedQty, 
            getDecimals(src), 
            getDecimals(dest) 
        );
    }

    event TradeExecute(
        address indexed sender,
        address src,
        uint srcAmount,
        address destToken,
        uint destAmount,
        address destAddress,
        uint auctionIndex
    );

    function trade(
        ERC20 srcToken,
        uint srcAmount,
        ERC20 destToken,
        address destAddress,
        uint conversionRate,
        bool validate
    )
        public
        payable
        returns(bool)
    {
        validate;

        require(tradeEnabled);
        require(msg.sender == kyberNetwork);

        AuctionData memory auctionData;
        auctionData.srcToken = srcToken == ETH_TOKEN_ADDRESS ? ERC20(weth) : srcToken;
        auctionData.dstToken = destToken == ETH_TOKEN_ADDRESS ? ERC20(weth) : destToken;
        auctionData.index = dutchX.getAuctionIndex(auctionData.dstToken, auctionData.srcToken);
        if (auctionData.index == 0) revert();

        uint actualSrcQty;

        if (srcToken == ETH_TOKEN_ADDRESS){
            require(srcAmount == msg.value);
            actualSrcQty = srcAmount * (BPS - feeBps) / BPS;
            weth.deposit.value(actualSrcQty)();
        } else {
            require(msg.value == 0);
            require(srcToken.transferFrom(msg.sender, address(this), srcAmount));
            actualSrcQty = srcAmount;
        }

        dutchX.deposit(auctionData.srcToken, actualSrcQty);
        dutchX.postBuyOrder(auctionData.dstToken, auctionData.srcToken, auctionData.index, actualSrcQty);

        uint destAmount;
        uint frtsIssued;
        (destAmount, frtsIssued) = dutchX.claimBuyerFunds(auctionData.dstToken, auctionData.srcToken, this,
            auctionData.index);
        dutchX.withdraw(auctionData.dstToken, destAmount);

        if (destToken == ETH_TOKEN_ADDRESS) {
            weth.withdraw(destAmount);
            destAmount = destAmount * (BPS - feeBps) / BPS;
            destAddress.transfer(destAmount);
        } else {
            require(auctionData.dstToken.transfer(destAddress, destAmount));
        }

        require(conversionRate <= calcRateFromQty(
            actualSrcQty, 
            destAmount, 
            getDecimals(srcToken), 
            getDecimals(destToken) 
        ));
        
        TradeExecute(
            msg.sender, 
            srcToken, 
            srcAmount, 
            destToken, 
            destAmount, 
            destAddress, 
            auctionData.index
        );

        return true;
    }

    event FeeUpdated(
        uint bps
    );

    function setFee(uint bps) public onlyAdmin {
        require(bps <= BPS);
        feeBps = bps;
        FeeUpdated(bps);
    }

    event TokenListed(
        ERC20 token
    );

    function listToken(ERC20 token)
        public
        onlyAdmin
    {
        require(address(token) != 0);

        listedTokens[token] = true;

        setDecimals(token);

        require(token.approve(dutchX, 2**255));

        TokenListed(token);
    }

    event TokenDelisted(ERC20 token);

    function delistToken(ERC20 token)
        public
        onlyAdmin
    {
        require(listedTokens[token] == true);
        listedTokens[token] == false;

        TokenDelisted(token);
    }

    event TradeEnabled(
        bool enable
    );

    function setDutchXFee() public {
        (dutchXFeeNum, dutchXFeeDen) = dutchX.getFeeRatio(this);

        
        if (dutchXFeeDen == 0) {
            tradeEnabled = false;
        } else {
            tradeEnabled = true;
        }

        TradeEnabled(tradeEnabled);
    }

    function disableTrade()
        public
        onlyAlerter
        returns(bool)
    {
        tradeEnabled = false;
        TradeEnabled(false);
        return true;
    }

    event KyberNetworkSet(
        address kyberNetwork
    );

    function setKyberNetwork(
        address _kyberNetwork
    )
        public
        onlyAdmin
    {
        require(_kyberNetwork != 0);
        kyberNetwork = _kyberNetwork;
        KyberNetworkSet(kyberNetwork);
    }

    event DutchXSet(
        DutchXExchange dutchX
    );

    function setDutchX(
        DutchXExchange _dutchX
    )
        public
        onlyAdmin
    {
        require(_dutchX != DutchXExchange(0));
        dutchX = _dutchX;
        DutchXSet(dutchX);
    }

    event Execution(bool success, address caller, address destination, uint value, bytes data);

    function executeTransaction(address destination, uint value, bytes data)
        public
        onlyOperator
    {
        if (destination.call.value(value)(data)) {
            Execution(true, msg.sender, destination, value, data);
        } else {
            Execution(false, msg.sender, destination, value, data);
        }
    }

    function sufficientLiquidity(ERC20 src, uint srcQty, ERC20 dest, uint num, uint den) internal view returns(bool) {

        uint buyVolume = dutchX.buyVolumes(dest, src);
        uint sellVolume = dutchX.sellVolumesCurrent(dest, src);

        
        require(sellVolume * num > sellVolume);
        uint outstandingVolume = (sellVolume * num) / den - buyVolume;

        if (outstandingVolume > srcQty) return true;

        return false;
    }
}