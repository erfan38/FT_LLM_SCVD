contract StreamityCrowdsale is Pauseble
{
    using SafeMath for uint;

    uint public stage = 0;

    event CrowdSaleFinished(string info);

    struct Ico {
        uint256 tokens;              
        uint startDate;              
        uint endDate;                
        uint8 discount;              
        uint8 discountFirstDayICO;   
    }

    Ico public ICO;

     
    function changeRate(uint256 _numerator, uint256 _denominator) public onlyOwner
        returns (bool success)
    {
        if (_numerator == 0) _numerator = 1;
        if (_denominator == 0) _denominator = 1;

        buyPrice = (_numerator.mul(DEC)).div(_denominator);

        return true;
    }

     
    function crowdSaleStatus() internal constant
        returns (string)
    {
        if (1 == stage) {
            return "Pre-ICO";
        } else if(2 == stage) {
            return "ICO first stage";
        } else if (3 == stage) {
            return "ICO second stage";
        } else if (4 >= stage) {
            return "feature stage";
        }

        return "there is no stage at present";
    }

     
    function sell(address _investor, uint256 amount) internal
    {
        uint256 _amount = (amount.mul(DEC)).div(buyPrice);

        if (1 == stage) {
            _amount = _amount.add(withDiscount(_amount, ICO.discount));
        }
        else if (2 == stage)
        {
            if (now <= ICO.startDate + 1 days)
            {
                  if (0 == ICO.discountFirstDayICO) {
                      ICO.discountFirstDayICO = 20;
                  }

                  _amount = _amount.add(withDiscount(_amount, ICO.discountFirstDayICO));
            } else {
                _amount = _amount.add(withDiscount(_amount, ICO.discount));
            }
        } else if (3 == stage) {
            _amount = _amount.add(withDiscount(_amount, ICO.discount));
        }

        if (ICO.tokens < _amount)
        {
            emit CrowdSaleFinished(crowdSaleStatus());
            pauseInternal();

            revert();
        }

        ICO.tokens = ICO.tokens.sub(_amount);
        avaliableSupply = avaliableSupply.sub(_amount);

        _transfer(this, _investor, _amount);
    }

     
    function startCrowd(uint256 _tokens, uint _startDate, uint _endDate, uint8 _discount, uint8 _discountFirstDayICO) public onlyOwner
    {
        require(_tokens * DEC <= avaliableSupply);   
        startIcoDate = _startDate;
        ICO = Ico (_tokens * DEC, _startDate, _startDate + _endDate * 1 days , _discount, _discountFirstDayICO);
        stage = stage.add(1);
        unpauseInternal();
    }

     
    function transferWeb3js(address _investor, uint256 _amount) external onlyOwner
    {
        sell(_investor, _amount);
    }

     
    function withDiscount(uint256 _amount, uint _percent) internal pure
        returns (uint256)
    {
        return (_amount.mul(_percent)).div(100);
    }
}

