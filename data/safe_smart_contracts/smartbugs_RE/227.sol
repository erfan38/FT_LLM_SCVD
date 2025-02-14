pragma solidity ^0.4.24;








contract MultiChanger {
    using SafeMath for uint256;
    using CheckedERC20 for ERC20;
    using ExternalCall for address;

    function() public payable {
        require(tx.origin != msg.sender);
    }

    function change(bytes callDatas, uint[] starts) public payable { 
        for (uint i = 0; i < starts.length - 1; i++) {
            require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    

    function sendEthValue(address target, uint256 value) external {
        
        require(target.call.value(value)());
    }

    function sendEthProportion(address target, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        
        require(target.call.value(value)());
    }

    

    function depositEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.deposit.value(amount)();
    }

    function depositEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = address(this).balance.mul(mul).div(div);
        etherToken.deposit.value(amount)();
    }

    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.withdraw(amount);
    }

    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
        etherToken.withdraw(amount);
    }

    

    function transferTokenAmount(address target, ERC20 fromToken, uint256 amount) external {
        require(fromToken.asmTransfer(target, amount));
    }

    function transferTokenProportion(address target, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.asmTransfer(target, amount));
    }

    function transferFromTokenAmount(ERC20 fromToken, uint256 amount) external {
        require(fromToken.asmTransferFrom(tx.origin, this, amount));
    }

    function transferFromTokenProportion(ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.asmTransferFrom(tx.origin, this, amount));
    }

    

    function multitokenChangeAmount(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 amount) external {
        if (fromToken.allowance(this, mtkn) == 0) {
            fromToken.asmApprove(mtkn, uint256(-1));
        }
        mtkn.change(fromToken, toToken, amount, minReturn);
    }

    function multitokenChangeProportion(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.multitokenChangeAmount(mtkn, fromToken, toToken, minReturn, amount);
    }
}