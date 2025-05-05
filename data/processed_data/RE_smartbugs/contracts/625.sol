pragma solidity ^0.4.19;

contract AKC is DSToken("AKC"), ERC223, Controlled {

    constructor() {
        setName("ARTWOOK Coin");
    }

    
    
    
    
    
    
    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {
        
        if (isContract(controller)) {
            if (!TokenController(controller).onTransfer(_from, _to, _amount))
               revert();
        }

        success = super.transferFrom(_from, _to, _amount);

        if (success && isContract(_to))
        {
            
            if(!_to.call(bytes4(keccak256("tokenFallback(address,uint256)")), _from, _amount)) {
                
                
                

                emit ReceivingContractTokenFallbackFailed(_from, _to, _amount);

                
            }
        }
    }

    



    function transferFrom(address _from, address _to, uint256 _amount, bytes _data)
        public
        returns (bool success)
    {
        
        if (isContract(controller)) {
            if (!TokenController(controller).onTransfer(_from, _to, _amount))
               revert();
        }

        require(super.transferFrom(_from, _to, _amount));

        if (isContract(_to)) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(_from, _amount, _data);
        }

        emit ERC223Transfer(_from, _to, _amount, _data);

        return true;
    }

    





    
    
    
    
    
    
    
    function transfer(
        address _to,
        uint256 _amount,
        bytes _data)
        public
        returns (bool success)
    {
        return transferFrom(msg.sender, _to, _amount, _data);
    }

    



    function transferFrom(address _from, address _to, uint256 _amount, bytes _data, string _custom_fallback)
        public
        returns (bool success)
    {
        
        if (isContract(controller)) {
            if (!TokenController(controller).onTransfer(_from, _to, _amount))
               revert();
        }

        require(super.transferFrom(_from, _to, _amount));

        if (isContract(_to)) {
            if(_to == address(this)) revert();
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.call.value(0)(bytes4(keccak256(_custom_fallback)), _from, _amount, _data);
        }

        emit ERC223Transfer(_from, _to, _amount, _data);

        return true;
    }

    



    function transfer(
        address _to,
        uint _amount,
        bytes _data,
        string _custom_fallback)
        public
        returns (bool success)
    {
        return transferFrom(msg.sender, _to, _amount, _data, _custom_fallback);
    }

    
    
    
    
    
    
    function approve(address _spender, uint256 _amount) returns (bool success) {
        
        if (isContract(controller)) {
            if (!TokenController(controller).onApprove(msg.sender, _spender, _amount))
                revert();
        }

        return super.approve(_spender, _amount);
    }

    function mint(address _guy, uint _wad) auth stoppable {
        super.mint(_guy, _wad);

        Transfer(0, _guy, _wad);
    }
    function burn(address _guy, uint _wad) auth stoppable {
        super.burn(_guy, _wad);

        Transfer(_guy, 0, _wad);
    }

    
    
    
    
    
    
    
    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) returns (bool success) {
        if (!approve(_spender, _amount)) revert();

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    
    
    
    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    
    
    
    function ()  payable {
        if (isContract(controller)) {
            if (! TokenController(controller).proxyPayment.value(msg.value)(msg.sender))
                revert();
        } else {
            revert();
        }
    }





    
    
    
    
    function claimTokens(address _token) onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        ERC20 token = ERC20(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        emit ClaimedTokens(_token, controller, balance);
    }





    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
}






library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}





