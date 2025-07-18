contract IcoRocketFuel is Ownable {

    using SafeMath for uint256;

     
    enum States {Active, Refunding, Closed}

    struct Crowdsale {
        address owner;         
        address refundWallet;  
        uint256 cap;           
        uint256 goal;          
        uint256 raised;        
        uint256 rate;          
        uint256 minInvest;     
        uint256 closingTime;   
        bool earlyClosure;     
        uint8 commission;      
        States state;          
    }

     
    address public commissionWallet;    

     
     
    mapping(address => Crowdsale) public crowdsales;

     
     
     
    mapping (address => mapping(address => uint256)) public deposits;

    modifier onlyCrowdsaleOwner(address _token) {
        require(
            msg.sender == crowdsales[_token].owner,
            "Failed to call function due to permission denied."
        );
        _;
    }

    modifier inState(address _token, States _state) {
        require(
            crowdsales[_token].state == _state,
            "Failed to call function due to crowdsale is not in right state."
        );
        _;
    }

    modifier nonZeroAddress(address _token) {
        require(
            _token != address(0),
            "Failed to call function due to address is 0x0."
        );
        _;
    }

    event CommissionWalletUpdated(
        address indexed _previoudWallet,  
        address indexed _newWallet        
    );

    event CrowdsaleCreated(
        address indexed _owner,  
        address indexed _token,  
        address _refundWallet,   
        uint256 _cap,            
        uint256 _goal,           
        uint256 _rate,           
        uint256 closingTime,     
        bool earlyClosure,       
        uint8 _commission        
    );

    event TokenBought(
        address indexed _buyer,  
        address indexed _token,  
        uint256 _value           
    );

    event CrowdsaleClosed(
        address indexed _setter,  
        address indexed _token    
    );

    event SurplusTokensRefunded(
        address _token,        
        address _beneficiary,  
        uint256 _surplus       
    );

    event CommissionPaid(
        address indexed _payer,        
        address indexed _token,        
        address indexed _beneficiary,  
        uint256 _value                 
    );

    event RefundsEnabled(
        address indexed _setter,  
        address indexed _token    
    );

    event CrowdsaleTokensRefunded(
        address indexed _token,         
        address indexed _refundWallet,  
        uint256 _value                  
    );

    event RaisedWeiClaimed(
        address indexed _beneficiary,  
        address indexed _token,        
        uint256 _value                 
    );

    event TokenClaimed(
        address indexed _beneficiary,  
        address indexed _token,        
        uint256 _value                 
    );

    event CrowdsalePaused(
        address indexed _owner,  
        address indexed _token   
    );

    event WeiRefunded(
        address indexed _beneficiary,  
        address indexed _token,        
        uint256 _value                 
    );

     
     

     
    function setCommissionWallet(
        address _newWallet
    )
        external
        onlyOwner
        nonZeroAddress(_newWallet)
    {
        emit CommissionWalletUpdated(commissionWallet, _newWallet);
        commissionWallet = _newWallet;
    }

     
    function createCrowdsale(
        address _token,
        address _refundWallet,
        uint256 _cap,
        uint256 _goal,
        uint256 _rate,
        uint256 _minInvest,
        uint256 _closingTime,
        bool _earlyClosure,
        uint8 _commission
    )
        external
        nonZeroAddress(_token)
        nonZeroAddress(_refundWallet)
    {
        require(
            crowdsales[_token].owner == address(0),
            "Failed to create crowdsale due to the crowdsale is existed."
        );

        require(
            _goal <= _cap,
            "Failed to create crowdsale due to goal is larger than cap."
        );

        require(
            _minInvest > 0,
            "Failed to create crowdsale due to minimum investment is 0."
        );

        require(
            _commission <= 100,
            "Failed to create crowdsale due to commission is larger than 100."
        );

         
        _cap.mul(_rate);

        crowdsales[_token] = Crowdsale({
            owner: msg.sender,
            refundWallet: _refundWallet,
            cap: _cap,
            goal: _goal,
            raised: 0,
            rate: _rate,
            minInvest: _minInvest,
            closingTime: _closingTime,
            earlyClosure: _earlyClosure,
            state: States.Active,
            commission: _commission
        });

        emit CrowdsaleCreated(
            msg.sender, 
            _token,
            _refundWallet,
            _cap, 
            _goal, 
            _rate,
            _closingTime,
            _earlyClosure,
            _commission
        );
    }

     
    function buyToken(
        address _token
    )
        external
        inState(_token, States.Active)
        nonZeroAddress(_token)
        payable
    {
        require(
            msg.value >= crowdsales[_token].minInvest,
            "Failed to buy token due to less than minimum investment."
        );

        require(
            crowdsales[_token].raised.add(msg.value) <= (
                crowdsales[_token].cap
            ),
            "Failed to buy token due to exceed cap."
        );

        require(
             
            block.timestamp < crowdsales[_token].closingTime,
            "Failed to buy token due to crowdsale is closed."
        );

        deposits[msg.sender][_token] = (
            deposits[msg.sender][_token].add(msg.value)
        );
        crowdsales[_token].raised = crowdsales[_token].raised.add(msg.value);
        emit TokenBought(msg.sender, _token, msg.value);        
    }

     
    function _goalReached(
        ERC20 _token
    )
        private
        nonZeroAddress(_token)
        view
        returns(bool) 
    {
        return (crowdsales[_token].raised >= crowdsales[_token].goal) && (
            _token.balanceOf(address(this)) >= 
            crowdsales[_token].raised.mul(crowdsales[_token].rate)
        );
    }

     
    function _refundSurplusTokens(
        ERC20 _token,
        address _beneficiary
    )
        private
        nonZeroAddress(_token)
        inState(_token, States.Closed)
    {
        uint256 _balance = _token.balanceOf(address(this));
        uint256 _surplus = _balance.sub(
            crowdsales[_token].raised.mul(crowdsales[_token].rate));
        emit SurplusTokensRefunded(_token, _beneficiary, _surplus);

        if (_surplus > 0) {
             
            _token.transfer(_beneficiary, _surplus);
        }
    }

     
    function _payCommission(
        address _token
    )
        private
        nonZeroAddress(_token)
        inState(_token, States.Closed)
        onlyCrowdsaleOwner(_token)
    {
         
        uint256 _commission = crowdsales[_token].raised
            .mul(uint256(crowdsales[_token].commission))
            .div(100);
        crowdsales[_token].raised = crowdsales[_token].raised.sub(_commission);
        emit CommissionPaid(msg.sender, _token, commissionWallet, _commission);
        commissionWallet.transfer(_commission);
    }

     
    function _refundCrowdsaleTokens(
        ERC20 _token,
        address _beneficiary
    )
        private
        nonZeroAddress(_token)
        inState(_token, States.Refunding)
    {
         
         
         
         
        crowdsales[_token].raised = 0;

        uint256 _value = _token.balanceOf(address(this));
        emit CrowdsaleTokensRefunded(_token, _beneficiary, _value);

        if (_value > 0) {         
             
            _token.transfer(_beneficiary, _token.balanceOf(address(this)));
        }
    }

     
    function _enableRefunds(
        address _token
    )
        private
        nonZeroAddress(_token)
        inState(_token, States.Active)      
    {
         
        crowdsales[_token].state = States.Refunding;
        emit RefundsEnabled(msg.sender, _token);
    }

     
    function finalize(
        address _token
    )
        external
        nonZeroAddress(_token)
        inState(_token, States.Active)        
        onlyCrowdsaleOwner(_token)
    {
        require(                    
            crowdsales[_token].earlyClosure || (
             
            block.timestamp >= crowdsales[_token].closingTime),                   
            "Failed to finalize due to crowdsale is opening."
        );

        if (_goalReached(ERC20(_token))) {
             
            crowdsales[_token].state = States.Closed;
            emit CrowdsaleClosed(msg.sender, _token);
            _refundSurplusTokens(
                ERC20(_token), 
                crowdsales[_token].refundWallet
            );
            _payCommission(_token);                        
        } else {
            _enableRefunds(_token);
            _refundCrowdsaleTokens(
                ERC20(_token), 
                crowdsales[_token].refundWallet
            );
        }
    }

     
    function pauseCrowdsale(
        address _token
    )  
        external      
        nonZeroAddress(_token)
        onlyOwner
        inState(_token, States.Active)
    {
        emit CrowdsalePaused(msg.sender, _token);
        _enableRefunds(_token);
        _refundCrowdsaleTokens(ERC20(_token), crowdsales[_token].refundWallet);
    }

     
    function claimRaisedWei(
        address _token,
        address _beneficiary
    )
        external
        nonZeroAddress(_token)
        nonZeroAddress(_beneficiary)
        inState(_token, States.Closed)
        onlyCrowdsaleOwner(_token)        
    {
        require(
            crowdsales[_token].raised > 0,
            "Failed to claim raised Wei due to raised Wei is 0."
        );

        uint256 _raisedWei = crowdsales[_token].raised;
        crowdsales[_token].raised = 0;
        emit RaisedWeiClaimed(msg.sender, _token, _raisedWei);
        _beneficiary.transfer(_raisedWei);
    }

     
    function claimToken(
        address _token
    )
        external 
        nonZeroAddress(_token)
        inState(_token, States.Closed)
    {
        require(
            deposits[msg.sender][_token] > 0,
            "Failed to claim token due to deposit is 0."
        );

         
        uint256 _value = (
            deposits[msg.sender][_token].mul(crowdsales[_token].rate)
        );
        deposits[msg.sender][_token] = 0;
        emit TokenClaimed(msg.sender, _token, _value);
        ERC20(_token).transfer(msg.sender, _value);
    }

     
    function claimRefund(
        address _token
    )
        public
        nonZeroAddress(_token)
        inState(_token, States.Refunding)
    {
        require(
            deposits[msg.sender][_token] > 0,
            "Failed to claim refund due to deposit is 0."
        );

        uint256 _value = deposits[msg.sender][_token];
        deposits[msg.sender][_token] = 0;
        emit WeiRefunded(msg.sender, _token, _value);
        msg.sender.transfer(_value);
    }
}