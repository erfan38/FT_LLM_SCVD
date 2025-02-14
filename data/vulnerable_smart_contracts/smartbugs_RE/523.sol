pragma solidity ^0.4.23;









interface IRegistry {
    function owner() external view returns (address _addr);
    function addressOf(bytes32 _name) external view returns (address _addr);
}

contract Treasury is
    Requestable
{
    
    address public owner;
    
    
    _ITrComptroller public comptroller;

    
    uint public capital;  
    uint public profits;  
    
    
    uint public capitalRaised;        
    uint public capitalRaisedTarget;  
    Ledger public capitalLedger;      

    
    uint public profitsSent;          
    uint public profitsTotal;         

    
    event Created(uint time);
    
    event ComptrollerSet(uint time, address comptroller, address token);
    
    event CapitalAdded(uint time, address indexed sender, uint amount);
    event CapitalRemoved(uint time, address indexed recipient, uint amount);
    event CapitalRaised(uint time, uint amount);
    
    event ProfitsReceived(uint time, address indexed sender, uint amount);
    
    event ExecutedSendCapital(uint time, address indexed bankrollable, uint amount);
    event ExecutedRecallCapital(uint time, address indexed bankrollable, uint amount);
    event ExecutedRaiseCapital(uint time, uint amount);
    event ExecutedDistributeCapital(uint time, uint amount);
    
    event DividendSuccess(uint time, address token, uint amount);
    event DividendFailure(uint time, string msg);

    
    
    
    
    constructor(address _registry, address _owner)
        Requestable(_registry)
        public
    {
        owner = _owner;
        capitalLedger = new Ledger(this);
        emit Created(now);
    }


    
    
    

    
    function initComptroller(_ITrComptroller _comptroller)
        public
    {
        
        require(msg.sender == owner);
        
        require(address(comptroller) == address(0));
        
        require(_comptroller.treasury() == address(this));
        comptroller = _comptroller;
        emit ComptrollerSet(now, _comptroller, comptroller.token());
    }


    
    
    

    
    function () public payable {
        profits += msg.value;
        profitsTotal += msg.value;
        emit ProfitsReceived(now, msg.sender, msg.value);
    }

    
    function issueDividend()
        public
        returns (uint _profits)
    {
        
        if (address(comptroller) == address(0)) {
            emit DividendFailure(now, "Comptroller not yet set.");
            return;
        }
        
        if (comptroller.wasSaleEnded() == false) {
            emit DividendFailure(now, "CrowdSale not yet completed.");
            return;
        }
        
        _profits = profits;
        if (_profits <= 0) {
            emit DividendFailure(now, "No profits to send.");
            return;
        }

        
        address _token = comptroller.token();
        profits = 0;
        profitsSent += _profits;
        require(_token.call.value(_profits)());
        emit DividendSuccess(now, _token, _profits);
    }


    
    
     

    
    
    function addCapital()
        public
        payable
    {
        capital += msg.value;
        if (msg.sender == address(comptroller)) {
            capitalRaised += msg.value;
            emit CapitalRaised(now, msg.value);
        }
        emit CapitalAdded(now, msg.sender, msg.value);
    }


    
    
    

    
    function executeSendCapital(address _bankrollable, uint _value)
        internal
        returns (bool _success, string _result)
    {
        
        if (_value > capital)
            return (false, "Not enough capital.");
        
        if (!_hasCorrectTreasury(_bankrollable))
            return (false, "Bankrollable does not have correct Treasury.");

        
        capital -= _value;
        capitalLedger.add(_bankrollable, _value);

        
        _ITrBankrollable(_bankrollable).addBankroll.value(_value)();
        emit CapitalRemoved(now, _bankrollable, _value);
        emit ExecutedSendCapital(now, _bankrollable, _value);
        return (true, "Sent bankroll to target.");
    }

    
    function executeRecallCapital(address _bankrollable, uint _value)
        internal
        returns (bool _success, string _result)
    {
        
        uint _prevCapital = capital;
        _ITrBankrollable(_bankrollable).removeBankroll(_value, "addCapital()");
        uint _recalled = capital - _prevCapital;
        capitalLedger.subtract(_bankrollable, _recalled);
        
        
        emit ExecutedRecallCapital(now, _bankrollable, _recalled);
        return (true, "Received bankoll back from target.");
    }

    
    function executeRaiseCapital(uint _value)
        internal
        returns (bool _success, string _result)
    {
        
        capitalRaisedTarget += _value;
        emit ExecutedRaiseCapital(now, _value);
        return (true, "Capital target raised.");
    }

    
    function executeDistributeCapital(uint _value)
        internal
        returns (bool _success, string _result)
    {
        if (_value > capital)
            return (false, "Not enough capital.");
        capital -= _value;
        profits += _value;
        profitsTotal += _value;
        emit CapitalRemoved(now, this, _value);
        emit ProfitsReceived(now, this, _value);
        emit ExecutedDistributeCapital(now, _value);
        return (true, "Capital moved to profits.");
    }


    
    
    

    function profitsTotal()
        public
        view
        returns (uint _amount)
    {
        return profitsSent + profits;
    }

    function profitsSendable()
        public
        view
        returns (uint _amount)
    {
        if (address(comptroller)==0) return 0;
        if (!comptroller.wasSaleEnded()) return 0;
        return profits;
    }

    
    function capitalNeeded()
        public
        view
        returns (uint _amount)
    {
        return capitalRaisedTarget > capitalRaised
            ? capitalRaisedTarget - capitalRaised
            : 0;
    }

    
    function capitalAllocated()
        public
        view
        returns (uint _amount)
    {
        return capitalLedger.total();
    }

    
    function capitalAllocatedTo(address _addr)
        public
        view
        returns (uint _amount)
    {
        return capitalLedger.balanceOf(_addr);
    }

    
    function capitalAllocation()
        public
        view
        returns (address[] _addresses, uint[] _amounts)
    {
        return capitalLedger.balances();
    }

    
    
    
    function _hasCorrectTreasury(address _addr)
        private
        returns (bool)
    {
        bytes32 _sig = bytes4(keccak256("getTreasury()"));
        bool _success;
        address _response;
        assembly {
            let x := mload(0x40)    
            mstore(x, _sig)         
            
            _success := call(
                10000,  
                _addr,  
                0,      
                x,      
                4,      
                x,      
                32      
            )
            
            _response := mload(x)
        }
        return _success ? _response == address(this) : false;
    }
}