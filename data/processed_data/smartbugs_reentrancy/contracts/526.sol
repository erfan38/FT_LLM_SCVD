pragma solidity ^0.4.24;

contract BATMO is FOMOEvents {
    using SafeMath for *;
    using NameFilter for string;
    using KeysCalc for uint256;

    PlayerBookInterface  private PlayerBook;





    OBOK public ObokContract;
    address private admin = msg.sender;
    address private admin2;
    string constant public name = "BATMO";
    string constant public symbol = "BATMO";
    uint256 private rndExtra_ = 1 minutes;     
    uint256 private rndGap_ = 1 minutes;         
    uint256 constant private rndInit_ = 2 hours;                
    uint256 constant private rndInc_ = 10 seconds;              
    uint256 constant private rndMax_ = 2 hours;                




    uint256 public rID_;    



    mapping (address => uint256) public pIDxAddr_;          
    mapping (bytes32 => uint256) public pIDxName_;          
    mapping (uint256 => BATMODatasets.Player) public plyr_;   
    mapping (uint256 => mapping (uint256 => BATMODatasets.PlayerRounds)) public plyrRnds_;    
    mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; 



    mapping (uint256 => BATMODatasets.Round) public round_;   
    mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      



    mapping (uint256 => BATMODatasets.TeamFee) public fees_;          
    mapping (uint256 => BATMODatasets.PotSplit) public potSplit_;     




    constructor(address otherAdmin, address token, address playerbook)
        public
    {
        admin2 = otherAdmin;
        ObokContract = OBOK(token);
        PlayerBook = PlayerBookInterface(playerbook);
        
        
        fees_[0] = BATMODatasets.TeamFee(47,10);   
       

        potSplit_[0] = BATMODatasets.PotSplit(15,10);  
    }




    



    modifier isActivated() {
        require(activated_ == true);
        _;
    }

    


    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
        require (msg.sender == tx.origin);
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0);
        
        _;
    }

    


    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000);
        require(_eth <= 100000000000000000000000);
        _;
    }





    


    function()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        BATMODatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        buyCore(_pID, plyr_[_pID].laff, _eventData_);
    }

    






    function buyXid(uint256 _affCode)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        BATMODatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        
        if (_affCode == 0 || _affCode == _pID)
        {
            
            _affCode = plyr_[_pID].laff;

        
        } else if (_affCode != plyr_[_pID].laff) {
            
            plyr_[_pID].laff = _affCode;
        }

        
        buyCore(_pID, _affCode, _eventData_);
    }

    function buyXaddr(address _affCode)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        BATMODatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        uint256 _affID;
        
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            
            _affID = plyr_[_pID].laff;

        
        } else {
            
            _affID = pIDxAddr_[_affCode];

            
            if (_affID != plyr_[_pID].laff)
            {
                
                plyr_[_pID].laff = _affID;
            }
        }
        
        buyCore(_pID, _affID, _eventData_);
    }

    function buyXname(bytes32 _affCode)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        BATMODatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        uint256 _affID;
        
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
            
            _affID = plyr_[_pID].laff;

        
        } else {
            
            _affID = pIDxName_[_affCode];

            
            if (_affID != plyr_[_pID].laff)
            {
                
                plyr_[_pID].laff = _affID;
            }
        }

        
        buyCore(_pID, _affID, _eventData_);
    }

    








    function reLoadXid(uint256 _affCode, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        
        BATMODatasets.EventReturns memory _eventData_;

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        
        if (_affCode == 0 || _affCode == _pID)
        {
            
            _affCode = plyr_[_pID].laff;

        
        } else if (_affCode != plyr_[_pID].laff) {
            
            plyr_[_pID].laff = _affCode;
        }

        
        reLoadCore(_pID, _affCode,  _eth, _eventData_);
    }

    function reLoadXaddr(address _affCode, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        
        BATMODatasets.EventReturns memory _eventData_;

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        uint256 _affID;
        
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            
            _affID = plyr_[_pID].laff;

        
        } else {
            
            _affID = pIDxAddr_[_affCode];

            
            if (_affID != plyr_[_pID].laff)
            {
                
                plyr_[_pID].laff = _affID;
            }
        }

        
        reLoadCore(_pID, _affID, _eth, _eventData_);
    }

    function reLoadXname(bytes32 _affCode, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        
        BATMODatasets.EventReturns memory _eventData_;

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        uint256 _affID;
        
        if (_affCode == '' || _affCode == plyr_[_pID].name)
        {
            
            _affID = plyr_[_pID].laff;

        
        } else {
            
            _affID = pIDxName_[_affCode];

            
            if (_affID != plyr_[_pID].laff)
            {
                
                plyr_[_pID].laff = _affID;
            }
        }

        
        reLoadCore(_pID, _affID, _eth, _eventData_);
    }

    



    function withdraw()
        isActivated()
        isHuman()
        public
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        uint256 _eth;

        
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            
            BATMODatasets.EventReturns memory _eventData_;

            
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            
            _eth = withdrawEarnings(_pID);

            
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            
            emit FOMOEvents.onWithdrawAndDistribute
            (
                msg.sender,
                plyr_[_pID].name,
                _eth,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.tokenAmount,
                _eventData_.genAmount
            );

        
        } else {
            
            _eth = withdrawEarnings(_pID);

            
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);

            
            emit FOMOEvents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
        }
    }

    























    function registerNameXID(string _nameString, uint256 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        
        emit FOMOEvents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXaddr(string _nameString, address _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        
        emit FOMOEvents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }

    function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _addr = msg.sender;
        uint256 _paid = msg.value;
        (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);

        uint256 _pID = pIDxAddr_[_addr];

        
        emit FOMOEvents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }




    




    function getBuyPrice()
        public
        view
        returns(uint256)
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
        else 
            return ( 75000000000000 ); 
    }

    





    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt + rndGap_)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt + rndGap_).sub(_now) );
        else
            return(0);
    }

    






    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        
        uint256 _rID = rID_;

        
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add( ((round_[_rID].pot).mul(48)) / 100 ),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }

        
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }

    


    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
        private
        view
        returns(uint256)
    {
        return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
    }

    













    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256)
    {
        
        uint256 _rID = rID_;

        return
        (
            round_[_rID].ico,               
            _rID,                           
            round_[_rID].keys,              
            round_[_rID].end,               
            round_[_rID].strt,              
            round_[_rID].pot,               
            (round_[_rID].team + (round_[_rID].plyr * 10)),     
            plyr_[round_[_rID].plyr].addr,  
            plyr_[round_[_rID].plyr].name,  
            rndTmEth_[_rID][0]             
            
        );
    }

    












    function getPlayerInfoByAddress(address _addr)
        public
        view
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        
        uint256 _rID = rID_;

        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];

        return
        (
            _pID,                               
            plyr_[_pID].name,                   
            plyrRnds_[_pID][_rID].keys,         
            plyr_[_pID].win,                    
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       
            plyr_[_pID].aff,                    
            plyrRnds_[_pID][_rID].eth           
        );
    }





    



    function buyCore(uint256 _pID, uint256 _affID, BATMODatasets.EventReturns memory _eventData_)
        private
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            
            core(_rID, _pID, msg.value, _affID, 0, _eventData_);

        
        } else {
            
            if (_now > round_[_rID].end && round_[_rID].ended == false)
            {
                
                round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);

                
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

                
                emit FOMOEvents.onBuyAndDistribute
                (
                    msg.sender,
                    plyr_[_pID].name,
                    msg.value,
                    _eventData_.compressedData,
                    _eventData_.compressedIDs,
                    _eventData_.winnerAddr,
                    _eventData_.winnerName,
                    _eventData_.amountWon,
                    _eventData_.newPot,
                    _eventData_.tokenAmount,
                    _eventData_.genAmount
                );
            }

            
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }

    



    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _eth, BATMODatasets.EventReturns memory _eventData_)
        private
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            
            
            
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);

            
            core(_rID, _pID, _eth, _affID, 0, _eventData_);

        
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            
            emit FOMOEvents.onReLoadAndDistribute
            (
                msg.sender,
                plyr_[_pID].name,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.tokenAmount,
                _eventData_.genAmount
            );
        }
    }

    



    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, BATMODatasets.EventReturns memory _eventData_)
        private
    {
        
        if (plyrRnds_[_pID][_rID].keys == 0)
            _eventData_ = managePlayer(_pID, _eventData_);

        
        if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
        {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }

        
        if (_eth > 1000000000)
        {

            
            uint256 _keys = (round_[_rID].eth).keysRec(_eth);

            
            if (_keys >= 1000000000000000000)
            {
            updateTimer(_keys, _rID);

            
            if (round_[_rID].plyr != _pID)
                round_[_rID].plyr = _pID;
            if (round_[_rID].team != _team)
                round_[_rID].team = _team;

            
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }

            
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][0] = _eth.add(rndTmEth_[_rID][0]);

            
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, 0, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, 0, _keys, _eventData_);

            
            endTx(_pID, 0, _eth, _keys, _eventData_);
        }
    }




    



    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }

    






    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        
        uint256 _now = now;

        
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).keysRec(_eth) );
        else 
            return ( (_eth).keys() );
    }

    





    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
        else 
            return ( (_keys).eth() );
    }




    


    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
        external
    {
        require (msg.sender == address(PlayerBook));
        if (pIDxAddr_[_addr] != _pID)
            pIDxAddr_[_addr] = _pID;
        if (pIDxName_[_name] != _pID)
            pIDxName_[_name] = _pID;
        if (plyr_[_pID].addr != _addr)
            plyr_[_pID].addr = _addr;
        if (plyr_[_pID].name != _name)
            plyr_[_pID].name = _name;
        if (plyr_[_pID].laff != _laff)
            plyr_[_pID].laff = _laff;
        if (plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    


    function receivePlayerNameList(uint256 _pID, bytes32 _name)
        external
    {
        require (msg.sender == address(PlayerBook));
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    



    function determinePID(BATMODatasets.EventReturns memory _eventData_)
        private
        returns (BATMODatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        
        if (_pID == 0)
        {
            
            _pID = PlayerBook.getPlayerID(msg.sender);
            bytes32 _name = PlayerBook.getPlayerName(_pID);
            uint256 _laff = PlayerBook.getPlayerLAff(_pID);

            
            pIDxAddr_[msg.sender] = _pID;
            plyr_[_pID].addr = msg.sender;

            if (_name != "")
            {
                pIDxName_[_name] = _pID;
                plyr_[_pID].name = _name;
                plyrNames_[_pID][_name] = true;
            }

            if (_laff != 0 && _laff != _pID)
                plyr_[_pID].laff = _laff;

            
            _eventData_.compressedData = _eventData_.compressedData + 1;
        }
        return (_eventData_);
    }

    

    



    function managePlayer(uint256 _pID, BATMODatasets.EventReturns memory _eventData_)
        private
        returns (BATMODatasets.EventReturns)
    {
        
        
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);

        
        plyr_[_pID].lrnd = rID_;

        
        _eventData_.compressedData = _eventData_.compressedData + 10;

        return(_eventData_);
    }

    


    function endRound(BATMODatasets.EventReturns memory _eventData_)
        private
        returns (BATMODatasets.EventReturns)
    {
        
        uint256 _rID = rID_;

        
        uint256 _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;

        
        uint256 _pot = round_[_rID].pot;

        
        
        uint256 _win = (_pot.mul(48)) / 100;   
        uint256 _dev = (_pot / 50);            
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
        uint256 _OBOK = (_pot.mul(potSplit_[_winTID].obok)) / 100;
        uint256 _res = (((_pot.sub(_win)).sub(_dev)).sub(_gen)).sub(_OBOK);

        
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
            _res = _res.add(_dust);
        }

        
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);

        

        admin.transfer(_dev / 2);
        admin2.transfer(_dev / 2);

        address(ObokContract).call.value(_OBOK.sub((_OBOK / 3).mul(2)))(bytes4(keccak256("donateDivs()")));  

        round_[_rID].pot = _pot.add(_OBOK / 3);  

        
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.tokenAmount = _OBOK;
        _eventData_.newPot = _res;

        
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);
        round_[_rID].pot += _res;

        return(_eventData_);
    }

    


    function updateGenVault(uint256 _pID, uint256 _rIDlast)
        private
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }

    


    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {
        
        uint256 _now = now;

        
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);

        
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

   
    


    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, BATMODatasets.EventReturns memory _eventData_)
        private
        returns(BATMODatasets.EventReturns)
    {
        
        uint256 _p1 = _eth / 100;  
        uint256 _dev = _eth / 50;  
        _dev = _dev.add(_p1);  

        uint256 _OBOK;
        if (!address(admin).call.value(_dev/2)() && !address(admin2).call.value(_dev/2)())
        {
            _OBOK = _dev;
            _dev = 0;
        }


        
        uint256 _aff = _eth / 10;

        
        
        if (_affID != _pID && plyr_[_affID].name != '') {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit FOMOEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
        } else {
            _OBOK = _aff;
        }

        
        _OBOK = _OBOK.add((_eth.mul(fees_[_team].obok)) / (100));
        if (_OBOK > 0)
        {
            
            uint256 _potAmount = _OBOK / 2;
            
            address(ObokContract).call.value(_OBOK.sub(_potAmount))(bytes4(keccak256("donateDivs()")));

            round_[_rID].pot = round_[_rID].pot.add(_potAmount);

            
            _eventData_.tokenAmount = _OBOK.add(_eventData_.tokenAmount);
        }

        return(_eventData_);
    }

    


    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, BATMODatasets.EventReturns memory _eventData_)
        private
        returns(BATMODatasets.EventReturns)
    {
        
        uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;

        
        _eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].obok)) / 100));

        
        uint256 _pot = _eth.sub(_gen);

        
        
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);

        
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);

        
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;

        return(_eventData_);
    }

    



    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
        private
        returns(uint256)
    {
        










        
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        
        
        uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);

        
        return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
    }

    



    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {
        
        updateGenVault(_pID, plyr_[_pID].lrnd);

        
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }

    


    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, BATMODatasets.EventReturns memory _eventData_)
        private
    {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);

        emit FOMOEvents.onEndTx
        (
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            plyr_[_pID].name,
            msg.sender,
            _eth,
            _keys,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.tokenAmount,
            _eventData_.genAmount,
            _eventData_.potAmount
        );
    }




    


    bool public activated_ = false;
    function activate()
        public
    {
        
        require(msg.sender == admin, "only admin can activate");


        
        require(activated_ == false, "FOMO Short already activated");

        
        activated_ = true;

        
        rID_ = 1;
            round_[1].strt = now + rndExtra_ - rndGap_;
            round_[1].end = now + rndInit_ + rndExtra_;
    }
}





library BATMODatasets {
    
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         
        bytes32 winnerName;         
        uint256 amountWon;          
        uint256 newPot;             
        uint256 tokenAmount;          
        uint256 genAmount;          
        uint256 potAmount;          
    }
    struct Player {
        address addr;   
        bytes32 name;   
        uint256 win;    
        uint256 gen;    
        uint256 aff;    
        uint256 lrnd;   
        uint256 laff;   
    }
    struct PlayerRounds {
        uint256 eth;    
        uint256 keys;   
        uint256 mask;   
        uint256 ico;    
    }
    struct Round {
        uint256 plyr;   
        uint256 team;   
        uint256 end;    
        bool ended;     
        uint256 strt;   
        uint256 keys;   
        uint256 eth;    
        uint256 pot;    
        uint256 mask;   
        uint256 ico;    
        uint256 icoGen; 
        uint256 icoAvg; 
    }
    struct TeamFee {
        uint256 gen;    
        uint256 obok;    
    }
    struct PotSplit {
        uint256 gen;    
        uint256 obok;    
    }
}





library KeysCalc {
    using SafeMath for *;
    





    function keysRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
    }

    





    function ethRec(uint256 _curKeys, uint256 _sellKeys)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
    }

    




    function keys(uint256 _eth)
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }

    




    function eth(uint256 _keys)
        internal
        pure
        returns(uint256)
    {
        return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}






