contract LoanTokenLogicDai is LoanTokenLogicStandard {

    uint256 public constant RAY = 10**27;

    // Mainnet
    /*IChai public constant chai = IChai(0x06AF07097C9Eeb7fD685c692751D5C66dB49c215);
    IPot public constant pot = IPot(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
    IERC20 public constant dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);*/

    // Kovan
    IChai public constant chai = IChai(0x71DD45d9579A499B58aa85F50E5E3B241Ca2d10d);
    IPot public constant pot = IPot(0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb);
    IERC20 public constant dai = IERC20(0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa);


    constructor(
        address _newOwner)
        public
        LoanTokenLogicStandard(_newOwner)
    {}

    /* Public functions */

    function mintWithChai(
        address receiver,
        uint256 depositAmount)
        external
        nonReentrant
        returns (uint256 mintAmount)
    {
        return _mintToken(
            receiver,
            depositAmount,
            true // withChai
        );
    }

    function mint(
        address receiver,
        uint256 depositAmount)
        external
        nonReentrant
        returns (uint256 mintAmount)
    {
        return _mintToken(
            receiver,
            depositAmount,
            false // withChai
        );
    }

    function burnToChai(
        address receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 chaiAmountPaid)
    {
        return _burnToken(
            burnAmount,
            receiver,
            true // toChai
        );
    }

    function burn(
        address receiver,
        uint256 burnAmount)
        external
        nonReentrant
        returns (uint256 loanAmountPaid)
    {
        return _burnToken(
            burnAmount,
            receiver,
            false // toChai
        );
    }

    function flashBorrow(
        uint256 borrowAmount,
        address borrower,
        address target,
        string calldata signature,
        bytes calldata data)
        external
        payable
        nonReentrant
        pausable(msg.sig)
        settlesInterest
        returns (bytes memory)
    {
        require(borrowAmount != 0, "38");

        _dsrWithdraw(borrowAmount);

        IERC20 _dai = _getDai();

        // save before balances
        uint256 beforeEtherBalance = address(this).balance.sub(msg.value);
        uint256 beforeAssetsBalance = _dai.balanceOf(address(this));

        // lock totalAssetSupply for duration of flash loan
        _flTotalAssetSupply = _underlyingBalance()
            .add(totalAssetBorrow());

        // transfer assets to calling 