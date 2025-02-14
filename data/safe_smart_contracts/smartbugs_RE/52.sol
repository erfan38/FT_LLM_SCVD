pragma solidity ^0.4.24;







library SafeMath {

  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    
    
    
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    
    return _a / _b;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}








contract MultiChanger is CanReclaimToken {
    using SafeMath for uint256;
    using CheckedERC20 for ERC20;

    
    
    
    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns (bool result) {
        
        assembly {
            let x := mload(0x40)   
            let d := add(data, 32) 
            result := call(
                sub(gas, 34710),   
                                   
                                   
                destination,
                value,
                add(d, dataOffset),
                dataLength,        
                x,
                0                  
            )
        }
    }

    function change(bytes callDatas, uint[] starts) public payable { 
        for (uint i = 0; i < starts.length - 1; i++) {
            require(externalCall(this, 0, callDatas, starts[i], starts[i + 1] - starts[i]));
        }
    }

    function sendEthValue(address target, bytes data, uint256 value) external {
        
        require(target.call.value(value)(data));
    }

    function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        
        require(target.call.value(value)(data));
    }

    function approveTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
        if (fromToken.allowance(this, target) != 0) {
            fromToken.asmApprove(target, 0);
        }
        fromToken.asmApprove(target, amount);
        
        require(target.call(data));
    }

    function approveTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        if (fromToken.allowance(this, target) != 0) {
            fromToken.asmApprove(target, 0);
        }
        fromToken.asmApprove(target, amount);
        
        require(target.call(data));
    }

    function transferTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
        require(fromToken.asmTransfer(target, amount));
        if (data.length != 0) {
            
            require(target.call(data));
        }
    }

    function transferTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        require(fromToken.asmTransfer(target, amount));
        if (data.length != 0) {
            
            require(target.call(data));
        }
    }

    function transferTokenProportionToOrigin(ERC20 token, uint256 mul, uint256 div) external {
        uint256 amount = token.balanceOf(this).mul(mul).div(div);
        
        require(token.asmTransfer(tx.origin, amount));
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

    

    function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
        etherToken.withdraw(amount);
    }

    function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
        uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
        etherToken.withdraw(amount);
    }

    

    function bancorSendEthValue(IBancorNetwork bancor, address[] path, uint256 value) external {
        bancor.convert.value(value)(path, value, 1);
    }

    function bancorSendEthProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        bancor.convert.value(value)(path, value, 1);
    }

    function bancorApproveTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        if (ERC20(path[0]).allowance(this, bancor) == 0) {
            ERC20(path[0]).asmApprove(bancor, uint256(-1));
        }
        bancor.claimAndConvert(path, amount, 1);
    }

    function bancorApproveTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
        if (ERC20(path[0]).allowance(this, bancor) == 0) {
            ERC20(path[0]).asmApprove(bancor, uint256(-1));
        }
        bancor.claimAndConvert(path, amount, 1);
    }

    function bancorTransferTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        ERC20(path[0]).asmTransfer(bancor, amount);
        bancor.convert(path, amount, 1);
    }

    function bancorTransferTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
        ERC20(path[0]).asmTransfer(bancor, amount);
        bancor.convert(path, amount, 1);
    }

    function bancorAlreadyTransferedTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
        bancor.convert(path, amount, 1);
    }

    function bancorAlreadyTransferedTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
        uint256 amount = ERC20(path[0]).balanceOf(bancor).mul(mul).div(div);
        bancor.convert(path, amount, 1);
    }

    

    function kyberSendEthProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
        uint256 value = address(this).balance.mul(mul).div(div);
        kyber.trade.value(value)(
            fromToken,
            value,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenAmount(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 amount) external {
        if (fromToken.allowance(this, kyber) == 0) {
            fromToken.asmApprove(kyber, uint256(-1));
        }
        kyber.trade(
            fromToken,
            amount,
            toToken,
            this,
            1 << 255,
            0,
            0
        );
    }

    function kyberApproveTokenProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
        this.kyberApproveTokenAmount(kyber, fromToken, toToken, amount);
    }
}