contract TokenSale {
  using SafeMath for uint256;
  
  EthertoteToken public token;

  address public admin;
  address public thisContractAddress;

   
  address public tokenContractAddress = 0x42be9831FFF77972c1D0E1eC0aA9bdb3CaA04D47;
  
   
   
  address public tokenBurnAddress = 0xadCa18DC9489C5FE5BdDf1A8a8C2623B66029198;
  
   
   
  address public ethRaisedAddress = 0x9F73D808807c71Af185FEA0c1cE205002c74123C;
  
  uint public preIcoPhaseCountdown;        
  uint public icoPhaseCountdown;           
  uint public postIcoPhaseCountdown;       
  
   
  bool public tokenSaleIsPaused;
  
   
  uint public tokenSalePausedTime;
  
   
  uint public tokenSaleResumedTime;
  
   
   
  uint public tokenSalePausedDuration;
  
   
  uint256 public weiRaised;
  
   
  uint public maxEthRaised = 9000;
  
   
   
   
  uint public maxWeiRaised = maxEthRaised.mul(1000000000000000000);

   
   
  uint public openingTime = 1535990400;
  uint public closingTime = openingTime.add(7 days);
  
   
   
  uint public rate = 1000000000000000;
  
   
  uint public minSpend = 100000000000000000;     
  uint public maxSpend = 100000000000000000000;  

  
   
  modifier onlyAdmin { 
        require(msg.sender == admin
        ); 
        _; 
  }
  
   
  event Deployed(string, uint);
  event SalePaused(string, uint);
  event SaleResumed(string, uint);
  event TokensBurned(string, uint);
  
  
  
  
  
  
 
  constructor() public {
    
    admin = msg.sender;
    thisContractAddress = address(this);

    token = EthertoteToken(tokenContractAddress);
    

    require(ethRaisedAddress != address(0));
    require(tokenContractAddress != address(0));
    require(tokenBurnAddress != address(0));

    preIcoPhaseCountdown = openingTime;
    icoPhaseCountdown = closingTime;
    
     
     
    postIcoPhaseCountdown = closingTime.add(14 days);
    
    emit Deployed("Ethertote Token Sale 