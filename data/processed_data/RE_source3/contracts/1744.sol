contract MakerV2Loan is MakerV2Base {

    // The address of the MKR token
    GemLike internal mkrToken;
    // The address of the WETH token
    GemLike internal wethToken;
    // The address of the WETH Adapter
    JoinLike internal wethJoin;
    // The address of the Jug
    JugLike internal jug;
    // The address of the Vault Manager (referred to as 'CdpManager' to match Maker's naming)
    ManagerLike internal cdpManager;
    // The address of the SCD Tub
    SaiTubLike internal tub;
    // The Maker Registry in which all supported collateral tokens and their adapters are stored
    MakerRegistry internal makerRegistry;
    // The Uniswap Exchange 