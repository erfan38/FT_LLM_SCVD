contract SaverExchangeCore is SaverExchangeHelper, DSMath {

    // first is empty to keep the legacy order in place
    enum ExchangeType { _, OASIS, KYBER, UNISWAP, ZEROX }

    enum ActionType { SELL, BUY }

    struct ExchangeData {
        address srcAddr;
        address destAddr;
        uint srcAmount;
        uint destAmount;
        uint minPrice;
        address wrapper;
        address exchangeAddr;
        bytes callData;
        uint256 price0x;
    }

    /// @notice Internal method that preforms a sell on 0x/on-chain
    /// @dev Usefull for other DFS 