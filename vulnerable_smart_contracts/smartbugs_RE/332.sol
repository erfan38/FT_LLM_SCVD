pragma solidity 0.4.19;



















contract EasyTrade {
    
  string constant public VERSION = "1.0.0";
  address constant public ZRX_TOKEN_ADDR = 0xe41d2489571d322189246dafa5ebde1f4699f498;
  
  address public admin; 
  address public feeAccount; 
  uint public serviceFee; 
  uint public collectedFee = 0; 
 
  event FillSellOrder(address account, address token, uint tokens, uint ethers, uint tokensSold, uint ethersObtained, uint tokensRefunded);
  event FillBuyOrder(address account, address token, uint tokens, uint ethers, uint tokensObtained, uint ethersSpent, uint ethersRefunded);
  
  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }
  
  modifier onlyFeeAccount() {
    require(msg.sender == feeAccount);
    _;
  }
 
  function EasyTrade(
    address admin_,
    address feeAccount_,
    uint serviceFee_) 
  {
    admin = admin_;
    feeAccount = feeAccount_;
    serviceFee = serviceFee_;
  } 
    
  
  function() public payable { 
      
      require(msg.sender == ZrxTrader.getWethAddress() || msg.sender == EtherDeltaTrader.getEtherDeltaAddresss());
  }

  
  
  function changeAdmin(address admin_) public onlyAdmin {
    admin = admin_;
  }
  
  
  
  function changeFeeAccount(address feeAccount_) public onlyAdmin {
    feeAccount = feeAccount_;
  }

  
  
  function changeFeePercentage(uint serviceFee_) public onlyAdmin {
    require(serviceFee_ < serviceFee);
    serviceFee = serviceFee_;
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function createSellOrder(
    address token, 
    uint tokensTotal, 
    uint ethersTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public
  {
    
    
    require(Token(token).transferFrom(msg.sender, this, tokensTotal));
    
    uint ethersObtained;
    uint tokensSold;
    uint tokensRefunded = tokensTotal;
    
    (ethersObtained, tokensSold) = fillOrdersForSellRequest(
      tokensTotal,
      exchanges,
      orderAddresses,
      orderValues,
      exchangeFees,
      v,
      r,
      s
    );
    
    
    require(ethersObtained > 0 && tokensSold >0);
    
    
    require(SafeMath.safeDiv(ethersTotal, tokensTotal) <= SafeMath.safeDiv(ethersObtained, tokensSold));
    
    
    tokensRefunded = SafeMath.safeSub(tokensTotal, tokensSold);
    
    
    if(tokensRefunded > 0) 
     require(Token(token).transfer(msg.sender, tokensRefunded));
    
    
    transfer(msg.sender, ethersObtained);
    
    FillSellOrder(msg.sender, token, tokensTotal, ethersTotal, tokensSold, ethersObtained, tokensRefunded);
  }
  
  
  
  
  
  
  
  
  
  
  
  function fillOrdersForSellRequest(
    uint tokensTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) internal returns(uint, uint)
  {
    uint totalEthersObtained = 0;
    uint tokensRemaining = tokensTotal;
    
    for (uint i = 0; i < orderAddresses.length; i++) {
   
      (totalEthersObtained, tokensRemaining) = fillOrderForSellRequest(
         totalEthersObtained,
         tokensRemaining,
         exchanges[i],
         orderAddresses[i],
         orderValues[i],
         exchangeFees[i],
         v[i],
         r[i],
         s[i]
      );

    }
    
    
    if(totalEthersObtained > 0) {
      uint fee =  SafeMath.safeMul(totalEthersObtained, serviceFee) / (1 ether);
      totalEthersObtained = collectServiceFee(SafeMath.min256(fee, totalEthersObtained), totalEthersObtained);
    }
    
    
    return (totalEthersObtained, SafeMath.safeSub(tokensTotal, tokensRemaining));
  }
  
  
  
  
  
  
  
  
  
  
  
  
  function fillOrderForSellRequest(
    uint totalEthersObtained,
    uint initialTokensRemaining,
    uint8 exchange,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
    ) internal returns(uint, uint)
  {
    uint ethersObtained = 0;
    uint tokensRemaining = initialTokensRemaining;
    
    
    require(exchangeFee < 10000000000000000);
    
    
    uint fillAmount = getFillAmount(
      tokensRemaining,
      exchange,
      orderAddresses,
      orderValues,
      exchangeFee,
      v,
      r,
      s
    );
    
    if(fillAmount > 0) {
          
      
      tokensRemaining = SafeMath.safeSub(tokensRemaining, fillAmount);
    
      if(exchange == 0) {
        
        ethersObtained = EtherDeltaTrader.fillBuyOrder(
          orderAddresses,
          orderValues,
          exchangeFee,
          fillAmount,
          v,
          r,
          s
        );    
      } 
      else {
        
        ethersObtained = ZrxTrader.fillBuyOrder(
          orderAddresses,
          orderValues,
          fillAmount,
          v,
          r,
          s
        );
        
        
        uint fee = SafeMath.safeMul(ethersObtained, exchangeFee) / (1 ether);
        ethersObtained = collectServiceFee(fee, ethersObtained);
    
      }
    }
         
    
    return (SafeMath.safeAdd(totalEthersObtained, ethersObtained), ethersObtained==0? initialTokensRemaining: tokensRemaining);
   
  }
  
  
  
  
  
  
  
  
  
  
  
  function createBuyOrder(
    address token, 
    uint tokensTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) public payable 
  {
    
    
    uint ethersTotal = msg.value;
    uint tokensObtained;
    uint ethersSpent;
    uint ethersRefunded = ethersTotal;
     
    require(tokensTotal > 0 && msg.value > 0);
    
    (tokensObtained, ethersSpent) = fillOrdersForBuyRequest(
      ethersTotal,
      exchanges,
      orderAddresses,
      orderValues,
      exchangeFees,
      v,
      r,
      s
    );
    
    
    require(ethersSpent > 0 && tokensObtained >0);
    
    
    require(SafeMath.safeDiv(ethersTotal, tokensTotal) >= SafeMath.safeDiv(ethersSpent, tokensObtained));

    
    ethersRefunded = SafeMath.safeSub(ethersTotal, ethersSpent);
    
    
    if(ethersRefunded > 0)
     require(msg.sender.call.value(ethersRefunded)());
   
    
    transferToken(token, msg.sender, tokensObtained);
    
    FillBuyOrder(msg.sender, token, tokensTotal, ethersTotal, tokensObtained, ethersSpent, ethersRefunded);
  }
  
  
  
  
  
  
  
  
  
  
  
  
  function fillOrdersForBuyRequest(
    uint ethersTotal,
    uint8[] exchanges,
    address[5][] orderAddresses,
    uint[6][] orderValues,
    uint[] exchangeFees,
    uint8[] v,
    bytes32[] r,
    bytes32[] s
  ) internal returns(uint, uint)
  {
    uint totalTokensObtained = 0;
    uint ethersRemaining = ethersTotal;
    
    for (uint i = 0; i < orderAddresses.length; i++) {
    
      if(ethersRemaining > 0) {
        (totalTokensObtained, ethersRemaining) = fillOrderForBuyRequest(
          totalTokensObtained,
          ethersRemaining,
          exchanges[i],
          orderAddresses[i],
          orderValues[i],
          exchangeFees[i],
          v[i],
          r[i],
          s[i]
        );
      }
    
    }
    
    
    return (totalTokensObtained, SafeMath.safeSub(ethersTotal, ethersRemaining));
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  function fillOrderForBuyRequest(
    uint totalTokensObtained,
    uint initialEthersRemaining,
    uint8 exchange,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint, uint)
  {
    uint tokensObtained = 0;
    uint ethersRemaining = initialEthersRemaining;
       
    
    require(exchangeFee < 10000000000000000);
     
    
    uint fillAmount = getFillAmount(
      ethersRemaining,
      exchange,
      orderAddresses,
      orderValues,
      exchangeFee,
      v,
      r,
      s
    );
   
    if(fillAmount > 0) {
     
      
      ethersRemaining = SafeMath.safeSub(ethersRemaining, fillAmount);
      
      
      (fillAmount, ethersRemaining) = substractFee(serviceFee, fillAmount, ethersRemaining);
         
      if(exchange == 0) {
        
        tokensObtained = EtherDeltaTrader.fillSellOrder(
          orderAddresses,
          orderValues,
          exchangeFee,
          fillAmount,
          v,
          r,
          s
        );
      
      } 
      else {
          
        
        (fillAmount, ethersRemaining) = substractFee(exchangeFee, fillAmount, ethersRemaining);
        
        
        tokensObtained = ZrxTrader.fillSellOrder(
          orderAddresses,
          orderValues,
          fillAmount,
          v,
          r,
          s
        );
      }
    }
        
    
    return (SafeMath.safeAdd(totalTokensObtained, tokensObtained), tokensObtained==0? initialEthersRemaining: ethersRemaining);
  }
  
  
  
  
  
  
  
  
  
  
  
  function getFillAmount(
    uint amount,
    uint8 exchange,
    address[5] orderAddresses,
    uint[6] orderValues,
    uint exchangeFee,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal returns(uint) 
  {
    uint availableAmount;
    if(exchange == 0) {
      availableAmount = EtherDeltaTrader.getAvailableAmount(
        orderAddresses,
        orderValues,
        exchangeFee,
        v,
        r,
        s
      );    
    } 
    else {
      availableAmount = ZrxTrader.getAvailableAmount(
        orderAddresses,
        orderValues,
        v,
        r,
        s
      );
    }
     
    return SafeMath.min256(amount, availableAmount);
  }
  
  
  
  
  
  
  function substractFee(
    uint feePercentage,
    uint fillAmount,
    uint ethersRemaining
  ) internal returns(uint, uint) 
  {       
      uint fee = SafeMath.safeMul(fillAmount, feePercentage) / (1 ether);
      
      if(ethersRemaining >= fee)
         ethersRemaining = collectServiceFee(fee, ethersRemaining);
      else {
         fillAmount = collectServiceFee(fee, SafeMath.safeAdd(fillAmount, ethersRemaining));
         ethersRemaining = 0;
      }
      return (fillAmount, ethersRemaining);
  }
  
  
  
  
  
  function collectServiceFee(uint fee, uint amount) internal returns(uint) {
    collectedFee = SafeMath.safeAdd(collectedFee, fee);
    return SafeMath.safeSub(amount, fee);
  }
  
  
  
  
  function transfer(address account, uint amount) internal {
    require(account.send(amount));
  }
    
  
  
  
  
  function transferToken(address token, address account, uint amount) internal {
    require(Token(token).transfer(account, amount));
  }
   
  
  
  function withdrawFees(uint amount) public onlyFeeAccount {
    require(collectedFee >= amount);
    collectedFee = SafeMath.safeSub(collectedFee, amount);
    require(feeAccount.send(amount));
  }
  
   
  
  
  function withdrawZRX(uint amount) public onlyAdmin {
    require(Token(ZRX_TOKEN_ADDR).transfer(admin, amount));
  }
}