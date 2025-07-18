pragma solidity ^0.4.21;




















contract OmniDex {
    


    
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

    modifier notContract() {
      require (msg.sender == tx.origin);
      _;
    }

    
    
    
    
    
    
    
    
    
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress]);
        _;
    }


    
    
    
    modifier antiEarlyWhale(uint256 _amountOfEthereum){
        address _customerAddress = msg.sender;

        
        
        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
            require(
                
                ambassadors_[_customerAddress] == true &&

                
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_

            );

            
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);

            
            _;
        } else {
            
            onlyAmbassadors = false;
            _;
        }

    }

    


    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );


    


    string public name = "OmniDex";
    string public symbol = "OMNI";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 18; 
    uint8 constant internal bankrollFee_ = 2; 
    uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
    uint256 constant internal magnitude = 2**64;

    
    
    address constant public giveEthBankrollAddress = 0x523a819E6dd9295Dba794C275627C95fa0644E8D;
    uint256 public totalEthBankrollRecieved; 
    uint256 public totalEthBankrollCollected; 

    
    uint256 public stakingRequirement = 30e18;

    
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 0.5 ether;
    uint256 constant internal ambassadorQuota_ = 3 ether; 



   


    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    
    mapping(address => bool) public administrators;

    
    bool public onlyAmbassadors = true;

    
    mapping(address => bool) public canAcceptTokens_; 



    


    


    function OmniDex()
        public
    {
        
        administrators[0xDEAD04D223220ACb19B46AFc84E04D490b872249] = true;

        
        ambassadors_[0xDEAD04D223220ACb19B46AFc84E04D490b872249] = true;
        
        ambassadors_[0x008ca4F1bA79D1A265617c6206d7884ee8108a78] = true;
        
        ambassadors_[0x9f06A41D9F00007009e4c1842D2f2aA9FC844a26] = true;
        
        ambassadors_[0xAAa2792AC2A60c694a87Cec7516E8CdFE85B0463] = true;
        
        ambassadors_[0x41a21b264f9ebf6cf571d4543a5b3ab1c6bed98c] = true;
        
        ambassadors_[0xAD6D6c25FCDAb2e737e8de31795df4c6bB6D9Bae] = true;
        
        
        
        
    }


    


    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        purchaseInternal(msg.value, _referredBy);
    }

    



    function()
        payable
        public
    {
        purchaseInternal(msg.value, 0x0);
    }

    



    function payBankroll() payable public {
      uint256 ethToPay = SafeMath.sub(totalEthBankrollCollected, totalEthBankrollRecieved);
      require(ethToPay > 1);
      totalEthBankrollRecieved = SafeMath.add(totalEthBankrollRecieved, ethToPay);
      if(!giveEthBankrollAddress.call.value(ethToPay).gas(400000)()) {
         totalEthBankrollRecieved = SafeMath.sub(totalEthBankrollRecieved, ethToPay);
      }
    }

    


    function reinvest()
        onlyStronghands()
        public
    {
        
        uint256 _dividends = myDividends(false); 

        
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        
        uint256 _tokens = purchaseTokens(_dividends, 0x0);

        
        onReinvestment(_customerAddress, _dividends, _tokens);
    }

    


    function exit()
        public
    {
        
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);

        
        withdraw();
    }

    


    function withdraw()
        onlyStronghands()
        public
    {
        
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); 

        
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        
        _customerAddress.transfer(_dividends);

        
        onWithdraw(_customerAddress, _dividends);
    }

    


    function sell(uint256 _amountOfTokens)
        onlyBagholders()
        public
    {
        
        address _customerAddress = msg.sender;
        
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);

        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
        uint256 _bankrollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankrollFee_), 100);

        
        uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankrollPayout);

        
        totalEthBankrollCollected = SafeMath.add(totalEthBankrollCollected, _bankrollPayout);

        
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

        
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;

        
        if (tokenSupply_ > 0) {
            
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }

        
        onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }


    



    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyBagholders()
        public
        returns(bool)
    {
        
        address _customerAddress = msg.sender;

        
        
        
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        
        if(myDividends(true) > 0) withdraw();

        
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);

        
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);


        
        Transfer(_customerAddress, _toAddress, _amountOfTokens);

        
        return true;
    }

    







    function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
      require(_to != address(0));
      require(canAcceptTokens_[_to] == true); 
      require(transfer(_to, _value)); 

      if (isContract(_to)) {
        AcceptsOmniDex receiver = AcceptsOmniDex(_to);
        require(receiver.tokenFallback(msg.sender, _value, _data));
      }

      return true;
    }

    



     function isContract(address _addr) private constant returns (bool is_contract) {
       
       uint length;
       assembly { length := extcodesize(_addr) }
       return length > 0;
     }

    
    


    function disableInitialStage()
        onlyAdministrator()
        public
    {
        onlyAmbassadors = false;
    }

    


    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }

    


    function setStakingRequirement(uint256 _amountOfTokens)
        onlyAdministrator()
        public
    {
        stakingRequirement = _amountOfTokens;
    }

    


    function setCanAcceptTokens(address _address, bool _value)
      onlyAdministrator()
      public
    {
      canAcceptTokens_[_address] = _value;
    }

    


    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }

    


    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }


    
    



    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return this.balance;
    }

    


    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }

    


    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    





    function myDividends(bool _includeReferralBonus)
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    


    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }

    


    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    


    function sellPrice()
        public
        view
        returns(uint256)
    {
        
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
            uint256 _bankrollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankrollFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankrollPayout);
            return _taxedEthereum;
        }
    }

    


    function buyPrice()
        public
        view
        returns(uint256)
    {
        
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
            uint256 _bankrollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankrollFee_), 100);
            uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _bankrollPayout);
            return _taxedEthereum;
        }
    }

    


    function calculateTokensReceived(uint256 _ethereumToSpend)
        public
        view
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
        uint256 _bankrollPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, bankrollFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _bankrollPayout);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }

    


    function calculateEthereumReceived(uint256 _tokensToSell)
        public
        view
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
        uint256 _bankrollPayout = SafeMath.div(SafeMath.mul(_ethereum, bankrollFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _bankrollPayout);
        return _taxedEthereum;
    }

    


    function etherToSendBankroll()
        public
        view
        returns(uint256) {
        return SafeMath.sub(totalEthBankrollCollected, totalEthBankrollRecieved);
    }


    



    
    function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
      notContract()
      internal
      returns(uint256) {

      uint256 purchaseEthereum = _incomingEthereum;
      uint256 excess;
      if(purchaseEthereum > 3 ether) { 
          if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 100 ether) { 
              purchaseEthereum = 3 ether;
              excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
          }
      }

      purchaseTokens(purchaseEthereum, _referredBy);

      if (excess > 0) {
        msg.sender.transfer(excess);
      }
    }


    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        antiEarlyWhale(_incomingEthereum)
        internal
        returns(uint256)
    {
        
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
        uint256 _bankrollPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, bankrollFee_), 100);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _undividedDividends), _bankrollPayout);

        totalEthBankrollCollected = SafeMath.add(totalEthBankrollCollected, _bankrollPayout);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        
        
        
        
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

        
        if(
            
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            
            _referredBy != msg.sender &&

            
            
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ){
            
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else {
            
            
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        
        if(tokenSupply_ > 0){

            
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

            
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));

        } else {
            
            tokenSupply_ = _amountOfTokens;
        }

        
        tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);

        
        
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[msg.sender] += _updatedPayouts;

        
        onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);

        return _amountOfTokens;
    }

    




    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
         (
            (
                
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;

        return _tokensReceived;
    }

    




     function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {

        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
            
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }


    
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
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