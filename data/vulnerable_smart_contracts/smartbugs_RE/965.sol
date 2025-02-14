pragma solidity ^0.4.21;





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
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




contract CommonTokensale is MultiOwnable, Pausable {

    using SafeMath for uint;

    address public beneficiary;
    uint public refundDeadlineTime;

    
    uint public balance;
    uint public balanceComision;
    uint public balanceComisionHold;
    uint public balanceComisionDone;

    
    CommonToken public token;

    uint public minPaymentUSD = 250;

    uint public minCapWei;
    uint public maxCapWei;

    uint public minCapUSD;
    uint public maxCapUSD;

    uint public startTime;
    uint public endTime;

    

    uint public totalTokensSold;  
    uint public totalWeiReceived; 
    uint public totalUSDReceived; 

    
    mapping (address => uint256) public buyerToSentWei;
    mapping (address => uint256) public sponsorToComisionDone;
    mapping (address => uint256) public sponsorToComision;
    mapping (address => uint256) public sponsorToComisionHold;
    mapping (address => uint256) public sponsorToComisionFromInversor;
    mapping (address => bool) public kicInversor;
    mapping (address => bool) public validateKYC;
    mapping (address => bool) public comisionInTokens;

    address[] public sponsorToComisionList;

    

    event ReceiveEthEvent(address indexed _buyer, uint256 _amountWei);
    event NewInverstEvent(address indexed _child, address indexed _sponsor);
    event ComisionEvent(address indexed _sponsor, address indexed _child, uint256 _value, uint256 _comision);
    event ComisionPayEvent(address indexed _sponsor, uint256 _value, uint256 _comision);
    event ComisionInversorInTokensEvent(address indexed _sponsor, bool status);
    event ChangeEndTimeEvent(address _sender, uint endTime, uint _date);
    event verifyKycEvent(address _sender, uint _date, bool _status);
    event payComisionSponsorTMSY(address _sponsor, uint _date, uint _value);
    event payComisionSponsorETH(address _sponsor, uint _date, uint _value);
    event withdrawEvent(address _sender, address _to, uint value, uint _date);
    event conversionToUSDEvent(uint _value, uint rateUsd, uint usds);
    event newRatioEvent(uint _value, uint date);
    event conversionETHToTMSYEvent(address _buyer, uint value, uint tokensE18SinBono, uint tokensE18Bono);
    event createContractEvent(address _token, address _beneficiary, uint _startTime, uint _endTime);
    
    uint public rateUSDETH;

    bool public isSoftCapComplete = false;

    
    mapping(address => bool) public inversors;
    address[] public inversorsList;

    
    mapping(address => address) public inversorToSponsor;

    constructor (
        address _token,
        address _beneficiary,
        uint _startTime,
        uint _endTime
    ) MultiOwnable() public {

        require(_token != address(0));
        token = CommonToken(_token);

        emit createContractEvent(_token, _beneficiary, _startTime, _endTime);

        beneficiary = _beneficiary;

        startTime = now;
        endTime   = 1544313600;


        minCapUSD = 400000;
        maxCapUSD = 4000000;
    }

    function setRatio(uint _rate) onlyOwner public returns (bool) {
      rateUSDETH = _rate;
      emit newRatioEvent(rateUSDETH, now);
      return true;
    }

    
    

    function burn(uint _value) onlyOwner public returns (bool) {
      return token.burn(_value);
    }

    function newInversor(address _newInversor, address _sponsor) onlyOwner public returns (bool) {
      inversors[_newInversor] = true;
      inversorsList.push(_newInversor);
      inversorToSponsor[_newInversor] = _sponsor;
      emit NewInverstEvent(_newInversor,_sponsor);
      return inversors[_newInversor];
    }
    function setComisionInvesorInTokens(address _inversor, bool _inTokens) onlyOwner public returns (bool) {
      comisionInTokens[_inversor] = _inTokens;
      emit ComisionInversorInTokensEvent(_inversor, _inTokens);
      return true;
    }
    function setComisionInTokens() public returns (bool) {
      comisionInTokens[msg.sender] = true;
      emit ComisionInversorInTokensEvent(msg.sender, true);
      return true;
    }
    function setComisionInETH() public returns (bool) {
      comisionInTokens[msg.sender] = false;
      emit ComisionInversorInTokensEvent(msg.sender, false);

      return true;
    }
    function inversorIsKyc(address who) public returns (bool) {
      return validateKYC[who];
    }
    function unVerifyKyc(address _inversor) onlyOwner public returns (bool) {
      require(!isSoftCapComplete);

      validateKYC[_inversor] = false;

      address sponsor = inversorToSponsor[_inversor];
      uint balanceHold = sponsorToComisionFromInversor[_inversor];

      
      balanceComision = balanceComision.sub(balanceHold);
      balanceComisionHold = balanceComisionHold.add(balanceHold);

      
      sponsorToComision[sponsor] = sponsorToComision[sponsor].sub(balanceHold);
      sponsorToComisionHold[sponsor] = sponsorToComisionHold[sponsor].add(balanceHold);

      
    
      emit verifyKycEvent(_inversor, now, false);
    }
    function verifyKyc(address _inversor) onlyOwner public returns (bool) {
      validateKYC[_inversor] = true;

      address sponsor = inversorToSponsor[_inversor];
      uint balanceHold = sponsorToComisionFromInversor[_inversor];

      
      balanceComision = balanceComision.add(balanceHold);
      balanceComisionHold = balanceComisionHold.sub(balanceHold);

      
      sponsorToComision[sponsor] = sponsorToComision[sponsor].add(balanceHold);
      sponsorToComisionHold[sponsor] = sponsorToComisionHold[sponsor].sub(balanceHold);

      
      
      emit verifyKycEvent(_inversor, now, true);
      
      


      return true;
    }
    function buyerToSentWeiOf(address who) public view returns (uint256) {
      return buyerToSentWei[who];
    }
    function balanceOf(address who) public view returns (uint256) {
      return token.balanceOf(who);
    }
    function balanceOfComision(address who)  public view returns (uint256) {
      return sponsorToComision[who];
    }
    function balanceOfComisionHold(address who)  public view returns (uint256) {
      return sponsorToComisionHold[who];
    }
    function balanceOfComisionDone(address who)  public view returns (uint256) {
      return sponsorToComisionDone[who];
    }

    function isInversor(address who) public view returns (bool) {
      return inversors[who];
    }
    function payComisionSponsor(address _inversor) private {
      
      
      if(comisionInTokens[_inversor]) {
        uint256 val = 0;
        uint256 valueHold = sponsorToComisionHold[_inversor];
        uint256 valueReady = sponsorToComision[_inversor];

        val = valueReady.add(valueHold);
        
        if(val > 0) {
          require(balanceComision >= valueReady);
          require(balanceComisionHold >= valueHold);
          uint256 comisionTokens = weiToTokens(val);

          sponsorToComision[_inversor] = 0;
          sponsorToComisionHold[_inversor] = 0;

          balanceComision = balanceComision.sub(valueReady);
          balanceComisionDone = balanceComisionDone.add(val);
          balanceComisionHold = balanceComisionHold.sub(valueHold);

          balance = balance.add(val);

          token.sell(_inversor, comisionTokens);
          emit payComisionSponsorTMSY(_inversor, now, val); 
        }
      } else {
        uint256 value = sponsorToComision[_inversor];

        
        if(value > 0) {
          require(balanceComision >= value);

          
          
          assert(isSoftCapComplete);

          
          assert(validateKYC[_inversor]);

          sponsorToComision[_inversor] = sponsorToComision[_inversor].sub(value);
          balanceComision = balanceComision.sub(value);
          balanceComisionDone = balanceComisionDone.add(value);

          _inversor.transfer(value);
          emit payComisionSponsorETH(_inversor, now, value); 

        }

      }
    }
    function payComision() public {
      address _inversor = msg.sender;
      payComisionSponsor(_inversor);
    }
    
    














    function isSoftCapCompleted() public view returns (bool) {
      return isSoftCapComplete;
    }
    function softCapCompleted() public {
      uint totalBalanceUSD = weiToUSD(balance.div(1e18));
      if(totalBalanceUSD >= minCapUSD) isSoftCapComplete = true;
    }

    function balanceComisionOf(address who) public view returns (uint256) {
      return sponsorToComision[who];
    }
    function getNow() public returns (uint) {
      return now;
    }
    
    function() public payable {
        

        uint256 _amountWei = msg.value;
        address _buyer = msg.sender;
        uint valueUSD = weiToUSD(_amountWei);

        require(now <= endTime, 'endtime');
        require(inversors[_buyer] != false, 'No invest');
        require(valueUSD >= minPaymentUSD, 'Min in USD not allowed');
        
        emit ReceiveEthEvent(_buyer, _amountWei);

        uint tokensE18SinBono = weiToTokens(msg.value);
        uint tokensE18Bono = weiToTokensBono(msg.value);
        emit conversionETHToTMSYEvent(_buyer, msg.value, tokensE18SinBono, tokensE18Bono);

        uint tokensE18 = tokensE18SinBono.add(tokensE18Bono);

        
        require(token.sell(_buyer, tokensE18SinBono), "Falla la venta");
        if(tokensE18Bono > 0)
          assert(token.sell(_buyer, tokensE18Bono));

        
        uint256 _amountSponsor = (_amountWei * 10) / 100;
        uint256 _amountBeneficiary = (_amountWei * 90) / 100;

        totalTokensSold = totalTokensSold.add(tokensE18);
        totalWeiReceived = totalWeiReceived.add(_amountWei);
        buyerToSentWei[_buyer] = buyerToSentWei[_buyer].add(_amountWei);

        
        if(!isSoftCapComplete) {
          uint256 totalBalanceUSD = weiToUSD(balance);
          if(totalBalanceUSD >= minCapUSD) {
            softCapCompleted();
          }
        }
        address sponsor = inversorToSponsor[_buyer];
        sponsorToComisionList.push(sponsor);

        if(validateKYC[_buyer]) {
          
          balanceComision = balanceComision.add(_amountSponsor);
          sponsorToComision[sponsor] = sponsorToComision[sponsor].add(_amountSponsor);

        } else {
          
          balanceComisionHold = balanceComisionHold.add(_amountSponsor);
          sponsorToComisionHold[sponsor] = sponsorToComisionHold[sponsor].add(_amountSponsor);
          sponsorToComisionFromInversor[_buyer] = sponsorToComisionFromInversor[_buyer].add(_amountSponsor);
        }


        payComisionSponsor(sponsor);


        balance = balance.add(_amountBeneficiary);
    }

    function weiToUSD(uint _amountWei) public view returns (uint256) {
      uint256 ethers = _amountWei;

      uint256 valueUSD = rateUSDETH.mul(_amountWei);

      emit conversionToUSDEvent(_amountWei, rateUSDETH, valueUSD.div(1e18));
      return valueUSD.div(1e18);
    }

    function weiToTokensBono(uint _amountWei) public view returns (uint256) {
      uint bono = 0;

      uint256 valueUSD = weiToUSD(_amountWei);

      
      
      if(valueUSD >= uint(500 * 10**18))   bono = 10;
      if(valueUSD >= uint(1000 * 10**18))   bono = 20;
      if(valueUSD >= uint(2500 * 10**18))   bono = 30;
      if(valueUSD >= uint(5000 * 10**18))   bono = 40;
      if(valueUSD >= uint(10000 * 10**18))   bono = 50;


      uint256 bonoUsd = valueUSD.mul(bono).div(100);
      uint256 tokens = bonoUsd.mul(tokensPerUSD());

      return tokens;
    }
    
    function weiToTokens(uint _amountWei) public view returns (uint256) {

        uint256 valueUSD = weiToUSD(_amountWei);

        uint256 tokens = valueUSD.mul(tokensPerUSD());

        return tokens;
    }

    function tokensPerUSD() public pure returns (uint256) {
        return 65; 
    }

    function canWithdraw() public view returns (bool);

    function withdraw(address _to, uint value) public returns (uint) {
        require(canWithdraw(), 'No es posible retirar');
        require(msg.sender == beneficiary, 'Sólo puede solicitar el beneficiario los fondos');
        require(balance > 0, 'Sin fondos');
        require(balance >= value, 'No hay suficientes fondos');
        require(_to.call.value(value).gas(1)(), 'No se que es');

        balance = balance.sub(value);
        emit withdrawEvent(msg.sender, _to, value,now);
        return balance;
    }

    
    function changeEndTime(uint _date) onlyOwner public returns (bool) {
     
      endTime = _date;
      refundDeadlineTime = endTime + 3 * 30 days;
      emit ChangeEndTimeEvent(msg.sender,endTime,_date);
      return true;
    }
}

