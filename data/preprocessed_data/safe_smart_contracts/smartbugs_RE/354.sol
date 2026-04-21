pragma solidity ^0.4.24;






contract DividendTokenERC667 is ERC667, Ownable
{
    using SafeMath for uint256;

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    uint constant POINTS_PER_WEI = 1e32;
    uint public dividendsTotal;
    uint public dividendsCollected;
    uint public totalPointsPerToken;
    mapping (address => uint) public creditedPoints;
    mapping (address => uint) public lastPointsPerToken;

    
    event CollectedDividends(uint time, address indexed account, uint amount);
    event DividendReceived(uint time, address indexed sender, uint amount);

    constructor(uint256 _totalSupply, address _custom_owner)
    public
    ERC667("Noteshares Token", "NST")
    Ownable(_custom_owner)
    {
        totalSupply = _totalSupply;
    }

    
    function receivePayment()
    internal
    {
        if (msg.value == 0) return;
        
        
        totalPointsPerToken = totalPointsPerToken.add((msg.value.mul(POINTS_PER_WEI)).div(totalSupply));
        dividendsTotal = dividendsTotal.add(msg.value);
        emit DividendReceived(now, msg.sender, msg.value);
    }
    
    
    

    
    
    function transfer(address _to, uint _value)
    public
    returns (bool success)
    {
        
        _updateCreditedPoints(msg.sender);
        _updateCreditedPoints(_to);
        return ERC20.transfer(_to, _value);
    }

    
    
    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool success)
    {
        _updateCreditedPoints(_from);
        _updateCreditedPoints(_to);
        return ERC20.transferFrom(_from, _to, _value);
    }

    
    
    function transferAndCall(address _to, uint _value, bytes _data)
    public
    returns (bool success)
    {
        _updateCreditedPoints(msg.sender);
        _updateCreditedPoints(_to);
        return ERC667.transferAndCall(_to, _value, _data);
    }

    
    function collectOwedDividends()
    internal
    returns (uint _amount)
    {
        
        _updateCreditedPoints(msg.sender);
        _amount = creditedPoints[msg.sender].div(POINTS_PER_WEI);
        creditedPoints[msg.sender] = 0;
        dividendsCollected = dividendsCollected.add(_amount);
        emit CollectedDividends(now, msg.sender, _amount);
        require(msg.sender.call.value(_amount)());
    }


    
    
    
    
    
    
    function _updateCreditedPoints(address _account)
    private
    {
        creditedPoints[_account] = creditedPoints[_account].add(_getUncreditedPoints(_account));
        lastPointsPerToken[_account] = totalPointsPerToken;
    }

    
    function _getUncreditedPoints(address _account)
    private
    view
    returns (uint _amount)
    {
        uint _pointsPerToken = totalPointsPerToken.sub(lastPointsPerToken[_account]);
        
        
        
        
        return _pointsPerToken.mul(balanceOf[_account]);
    }


    
    
    
    
    function getOwedDividends(address _account)
    public
    constant
    returns (uint _amount)
    {
        return (_getUncreditedPoints(_account).add(creditedPoints[_account])).div(POINTS_PER_WEI);
    }
}
