pragma solidity ^0.4.21;


































contract DailyDivs {
    


    
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
    
    uint ACTIVATION_TIME = 1538938800;


    
    
    
    modifier antiEarlyWhale(uint256 _amountOfEthereum){
        address _customerAddress = msg.sender;
        
        if (now >= ACTIVATION_TIME) {
            onlyAmbassadors = false;
        }

        
        
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


    


    string public name = "DailyDivs";
    string public symbol = "DDT";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 20; 
    uint8 constant internal fundFee_ = 5; 
    uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
    uint256 constant internal magnitude = 2**64;

    
    
    address constant public giveEthFundAddress = 0xd9092D94F74E6b5D408DBd3eCC88f3e5810d1e98;
    uint256 public totalEthFundRecieved; 
    uint256 public totalEthFundCollected; 

    
    uint256 public stakingRequirement = 1e18;

    
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 8 ether;
    uint256 constant internal ambassadorQuota_ = 8 ether;



   


    
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    
    mapping(address => bool) public administrators;

    
    bool public onlyAmbassadors = true;

    
    mapping(address => bool) public canAcceptTokens_; 



    


    


    function DailyDivs()
        public
    {
        
        administrators[0x0E7b52B895E3322eF341004DC6CB5C63e1d9b1c5] = true;
        
        
        ambassadors_[0x0E7b52B895E3322eF341004DC6CB5C63e1d9b1c5] = true;

        
        ambassadors_[0x4A42500b817439cF9B10b4d3edf68bb63Ed0A89B] = true;
        
        
        ambassadors_[0x642e0ce9ae8c0d8007e0acaf82c8d716ff8c74c1] = true;
        
        
        ambassadors_[0xeafe863757a2b2a2c5c3f71988b7d59329d09a78] = true;
        
        
        ambassadors_[0x03B434e2dC43184538ED148f71c097b54f87EBBd] = true;
        
        
        ambassadors_[0x8f1A667590014BF2e78b88EB112970F9E3E340E5] = true;
        
        
        ambassadors_[0x6CF441B689683D3049f11B02c001E14bd0d86421] = true;
        
        
            ambassadors_[0xa39334D8363d6aAF50372313efaa4cF8bDD50a30] = true;
        
        
        ambassadors_[0xEc31176d4df0509115abC8065A8a3F8275aafF2b] = true;
        
        
        
        
        
    }


    


    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        
        require(tx.gasprice <= 0.05 szabo);
        purchaseInternal(msg.value, _referredBy);
    }

    



    function()
        payable
        public
    {
        
        require(tx.gasprice <= 0.01 szabo);
        purchaseInternal(msg.value, 0x0);
    }

    



    function payFund() payable public {
      uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
      require(ethToPay > 1);
      totalEthFundRecieved = SafeMath.add(totalEthFundRecieved, ethToPay);
      if(!giveEthFundAddress.call.value(ethToPay).gas(400000)()) {
         totalEthFundRecieved = SafeMath.sub(totalEthFundRecieved, ethToPay);
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
        uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);

        
        uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);

        
        totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);

        
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
        AcceptsDailyDivs receiver = AcceptsDailyDivs(_to);
        require(receiver.tokenFallback(msg.sender, _value, _data));
      }

      return true;
    }

    



     function isContract(address _addr) private constant returns (bool is_contract) {
       
       uint length;
       assembly { length := extcodesize(_addr) }
       return length > 0;
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
            uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
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
            uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
            uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _fundPayout);
            return _taxedEthereum;
        }
    }

    


    function calculateTokensReceived(uint256 _ethereumToSpend)
        public
        view
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
        uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, fundFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _fundPayout);
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
        uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
        return _taxedEthereum;
    }

    


    function etherToSendFund()
        public
        view
        returns(uint256) {
        return SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
    }


    



    
    function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
      notContract()
      internal
      returns(uint256) {

      uint256 purchaseEthereum = _incomingEthereum;
      uint256 excess;
      if(purchaseEthereum > 2 ether) { 
          if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 200 ether) { 
              purchaseEthereum = 2 ether;
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
        uint256 _fundPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, fundFee_), 100);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _undividedDividends), _fundPayout);

        totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);

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