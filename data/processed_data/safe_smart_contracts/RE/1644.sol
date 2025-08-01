contract CompoundResolver is CompoundHelper {

    event LogMint(address erc20, address cErc20, uint tokenAmt, address owner);
    event LogRedeem(address erc20, address cErc20, uint tokenAmt, address owner);
    event LogBorrow(address erc20, address cErc20, uint tokenAmt, address owner);
    event LogRepay(address erc20, address cErc20, uint tokenAmt, address owner);

    /**
     * @dev Deposit ETH/ERC20 and mint Compound Tokens
     */
    function mintCEth(uint tokenAmt) internal {
        CETHInterface cToken = CETHInterface(getCETHAddress());
        cToken.mint.value(tokenAmt)();
        emit LogMint(
            getAddressETH(),
            getCETHAddress(),
            tokenAmt,
            msg.sender
        );
    }

    /**
     * @dev Redeem ETH/ERC20 and mint Compound Tokens
     * @param tokenAmt Amount of token To Redeem
     */
    function redeemEth(uint tokenAmt) internal {
        CTokenInterface cToken = CTokenInterface(getCETHAddress());
        setApproval(getCETHAddress(), 10**30, getCETHAddress());
        require(cToken.redeemUnderlying(tokenAmt) == 0, "something went wrong");
        emit LogRedeem(
            getAddressETH(),
            getCETHAddress(),
            tokenAmt,
            address(this)
        );
    }

    /**
     * @dev borrow ETH/ERC20
     */
    function borrow(uint tokenAmt) internal {
        require(CTokenInterface(getCUSDCAddress()).borrow(tokenAmt) == 0, "got collateral?");
        emit LogBorrow(
            getAddressUSDC(),
            getCUSDCAddress(),
            tokenAmt,
            address(this)
        );
    }

    /**
     * @dev Pay Debt ETH/ERC20
     */
    function repayUsdc(uint tokenAmt) internal {
        CERC20Interface cToken = CERC20Interface(getCUSDCAddress());
        setApproval(getAddressUSDC(), tokenAmt, getCUSDCAddress());
        require(cToken.repayBorrow(tokenAmt) == 0, "transfer approved?");
        emit LogRepay(
            getAddressUSDC(),
            getCUSDCAddress(),
            tokenAmt,
            address(this)
        );
    }

}


