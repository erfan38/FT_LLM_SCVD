contract NekoToken {
     
     
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }
    
     
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
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

     event onWin(
        address indexed customerAddress,
        uint256 ethereumWon
    );
    
     
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    
     
    string public name = "NEKO TOKEN";
    string public symbol = "NEKO";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 4;               
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;
    
     
    uint256 public stakingRequirement = 100e18;
    
     
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 5 ether;
    uint256 constant internal ambassadorQuota_ = 10 ether;
    
    
    
    
     
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;

    uint256 internal jackpot_ = 0;
    
     
    mapping(address => bool) public administrators;
    
     
    bool public onlyAmbassadors = true;
    
    address Master;

    uint256 jackpotThreshold;

    uint jackpotFactor = 250;

    uint256 jackpotCounter = 0;

    address lastWinner = 0x0000000000000000000000000000000000000000;


     
     
    function NekoToken()
        public
    {
         
        administrators[msg.sender] = true;
        
        ambassadors_[0xa9eB31931417d89b233681dfb319783b1703C998] = true;
        ambassadors_[0x3662496Bd906054f535D534c46d130A4ee36624C] = true;
        ambassadors_[0x83c0Efc6d8B16D87BFe1335AB6BcAb3Ed3960285] = true;
        ambassadors_[0xAD6D6c25FCDAb2e737e8de31795df4c6bB6D9Bae] = true;
         
        ambassadors_[0x4F4eBF556CFDc21c3424F85ff6572C77c514Fcae] = true;

        Master = msg.sender;

        onlyAmbassadors = true;
   
        jackpotThreshold = random() * 1e15 * jackpotFactor;       
        

    }
    
     
     
    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        purchaseTokens(msg.value, _referredBy);
        
    }
    
     
    function()
        payable
        public
    {
        purchaseTokens(msg.value, 0x0);
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
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        
         
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
        
         
         
         
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
         
        if(myDividends(true) > 0) withdraw();
        
         
         
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);
  
         
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

         
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
        
         
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);
        
         
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        
         
        Transfer(_customerAddress, _toAddress, _taxedTokens);
        
         
        return true;
       
    }
    
     
     
  
    function disableInitialStage()
        onlyAdministrator
        public
    {
        onlyAmbassadors = true;
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
    
     
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }

     
    function setJackpotFactor(uint _factor)
        onlyAdministrator()
        public
    {
        jackpotFactor = _factor;
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

    
    function jackpot()
        public
        view
        returns(uint256)
    {
        return jackpot_;
    }

      
    function getLastWinner()
        public
        view
        returns(address)
    {
        return lastWinner;
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
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
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
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
    
     
    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        view 
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
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
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }
    
    
     

    
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        antiEarlyWhale(_incomingEthereum)
        internal
        returns(uint256)
    {
         
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 4);    

         
       
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);         
        _dividends = SafeMath.sub(_dividends, _referralBonus);         
        
        
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

         

        uint256 _fee = _dividends * magnitude;     

        jackpotCounter += _incomingEthereum;                

               
 
         
         
         
         
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        
         
        if(
             
            _referredBy != 0x0000000000000000000000000000000000000000 &&

             
            _referredBy != _customerAddress &&
            
             
             
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ){
             
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);

            jackpot_ = SafeMath.add(jackpot_, _referralBonus);

        } else {
             
             

            jackpot_ = SafeMath.add(jackpot_, _referralBonus);

            referralBalance_[Master] = SafeMath.add(referralBalance_[Master], _referralBonus);

        }
        
         
        if(tokenSupply_ > 0){
            
             
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 
             
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
            
             
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        
        } else {
             
            tokenSupply_ = _amountOfTokens;
        }
        
         
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
         
         
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;
        
         
         
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);

        checkJackpot(msg.sender);
        
        
        return _amountOfTokens;
    }


    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
    }


    function checkJackpot(address _jackpotAddress)
        private
        returns(uint256)
        {
        
        if (jackpotCounter >= jackpotThreshold) {     
             
             
             
            uint256 winnings = jackpot_;
             
            referralBalance_[_jackpotAddress] = SafeMath.add(referralBalance_[_jackpotAddress], jackpot_);
            jackpot_ = 0;
            jackpotCounter = 0;
            jackpotThreshold = random() * 1e15 * jackpotFactor;
            lastWinner = _jackpotAddress;

            onWin(msg.sender, winnings);
            
            return winnings;
        }
        
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