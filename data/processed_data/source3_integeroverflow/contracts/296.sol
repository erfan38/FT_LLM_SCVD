contract SuperCard is SPCevents {
    using SafeMath for *;
    using NameFilter for string;

    PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xbac825cdb506dcf917a7715a4bf3fa1b06abe3e4);





    address private admin = msg.sender;
    string constant public name   = "SuperCard";
    string constant public symbol = "SPC";
    uint256 private rndExtra_     = 0;     
    uint256 private rndGap_ = 2 minutes;         
    uint256 constant private rndInit_ = 6 hours;           
    uint256 constant private rndInc_ = 30 seconds;              
    uint256 constant private rndMax_ = 24 hours;                




    uint256 public airDropPot_;             
    uint256 public airDropTracker_ = 0;     
    uint256 public rID_;    
    uint256 public pID_;    
/
  modifier isActivated() {
        if ( activated_ == false ){
          if ( (now >= pre_active_time) &&  (pre_active_time > 0) ){
            activated_ = true;

            
            rID_ = 1;
            round_[1].strt = now + rndExtra_ - rndGap_;
            round_[1].end = now + rndInit_ + rndExtra_;
          }
        }
        require(activated_ == true, "its not ready yet.");
        _;
    }

    
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;
    }





    
    function()
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        SPCdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
    }
	
    function buyXname(bytes32 _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        SPCdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
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

        
        buyCore(_pID, _affID, 2, _eventData_);
    }

    function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        
        SPCdatasets.EventReturns memory _eventData_;

        
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
	
    function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        
        SPCdatasets.EventReturns memory _eventData_;

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        
        if (_affCode == 0 || _affCode == _pID)
        {
            
            _affCode = plyr_[_pID].laff;

        
        } else if (_affCode != plyr_[_pID].laff) {
            
            plyr_[_pID].laff = _affCode;
        }

        
        reLoadCore(_pID, _affCode, _eth, _eventData_);
    }

    function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
        isActivated()
        isHuman()
        isWithinLimits(_eth)
        public
    {
        
        SPCdatasets.EventReturns memory _eventData_;

        
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
	
	    
    

    
    function withdraw()
        isActivated()
        isHuman()
        public
    {
		
        uint256 myrID = rID_;

        
        uint256 _now = now;

        
        uint256 _pID = pIDxAddr_[msg.sender];

        
        uint256 upperLimit = 0;
        uint256 usedGen = 0;

        
        uint256 ethout = 0;   
        
        uint256 over_gen = 0;

        updateGenVault(_pID, plyr_[_pID].lrnd);

        if (plyr_[_pID].gen > 0)
        {
          upperLimit = (calceth(plyrRnds_[_pID][myrID].keys).mul(105))/100;
          if(plyr_[_pID].gen >= upperLimit)
          {
            over_gen = (plyr_[_pID].gen).sub(upperLimit);

            round_[myrID].keys = (round_[myrID].keys).sub(plyrRnds_[_pID][myrID].keys);
            plyrRnds_[_pID][myrID].keys = 0;

            round_[myrID].pot = (round_[myrID].pot).add(over_gen);
              
            usedGen = upperLimit;       
          }
          else
          {
            plyrRnds_[_pID][myrID].keys = (plyrRnds_[_pID][myrID].keys).sub(calckeys(((plyr_[_pID].gen).mul(100))/105));
            round_[myrID].keys = (round_[myrID].keys).sub(calckeys(((plyr_[_pID].gen).mul(100))/105));
            usedGen = plyr_[_pID].gen;
          }

          ethout = ((plyr_[_pID].win).add(plyr_[_pID].aff)).add(usedGen);
        }
        else
        {
          ethout = ((plyr_[_pID].win).add(plyr_[_pID].aff));
        }

        plyr_[_pID].win = 0;
        plyr_[_pID].gen = 0;
        plyr_[_pID].aff = 0;

        plyr_[_pID].addr.transfer(ethout);

        
        if (_now > round_[myrID].end && round_[myrID].ended == false && round_[myrID].plyr != 0)
        {
            
            SPCdatasets.EventReturns memory _eventData_;

            
            round_[myrID].ended = true;
            _eventData_ = endRound(_eventData_);

            
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            
            emit SPCevents.onWithdrawAndDistribute
            (
                msg.sender,
                plyr_[_pID].name,
                ethout,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.P3DAmount,
                _eventData_.genAmount
            );

        
        } else {
            
            emit SPCevents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, ethout, _now);
        }
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

        
        emit SPCevents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
    }




    
    function getBuyPrice()
        public
        view
        returns(uint256)
    {
        
        return(10000000000000000);
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
        
        return
        (
            plyr_[_pID].win,
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
            plyr_[_pID].aff
        );
    }

     
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
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
            rndTmEth_[_rID][0],             
            rndTmEth_[_rID][1],             
            rndTmEth_[_rID][2],             
            rndTmEth_[_rID][3],             
            airDropTracker_ + (airDropPot_ * 1000)              
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
	
	function buyXaddr(address _affCode, uint256 _team)
        isActivated()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        
        SPCdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);

        
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

        
        buyCore(_pID, _affID, 2, _eventData_);
    }





    
    function buyCore(uint256 _pID, uint256 _affID, uint256 _team, SPCdatasets.EventReturns memory _eventData_)
        private
    {
        
        uint256 _rID = rID_;

        
        uint256 _now = now;

        
        if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            
            core(_rID, _pID, msg.value, _affID, 2, _eventData_);

        
        } else {
            
            if (_now > round_[_rID].end && round_[_rID].ended == false)
            {
                
                round_[_rID].ended = true;
                _eventData_ = endRound(_eventData_);

                
                _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

                
                emit SPCevents.onBuyAndDistribute
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
                    _eventData_.P3DAmount,
                    _eventData_.genAmount
                );
            }

            
            plyr_[_pID].win = plyr_[_pID].win.add(msg.value);
        }
    }

    
    function genLimit(uint256 _pID) 
    private 
    returns(uint256)
    {
		
        uint256 myrID = rID_;

      uint256 upperLimit = 0;
      uint256 usedGen = 0;
      
      uint256 over_gen = 0;
      uint256 eth_can_use = 0;

      uint256 tempnum = 0;

      updateGenVault(_pID, plyr_[_pID].lrnd);

      if (plyr_[_pID].gen > 0)
      {
        upperLimit = ((plyrRnds_[_pID][myrID].keys).mul(105))/10000;
        if(plyr_[_pID].gen >= upperLimit)
        {
          over_gen = (plyr_[_pID].gen).sub(upperLimit);

          round_[myrID].keys = (round_[myrID].keys).sub(plyrRnds_[_pID][myrID].keys);
          plyrRnds_[_pID][myrID].keys = 0;

          round_[myrID].pot = (round_[myrID].pot).add(over_gen);
            
          usedGen = upperLimit;
        }
        else
        {
          tempnum = ((plyr_[_pID].gen).mul(10000))/105;

          plyrRnds_[_pID][myrID].keys = (plyrRnds_[_pID][myrID].keys).sub(tempnum);
          round_[myrID].keys = (round_[myrID].keys).sub(tempnum);

          usedGen = plyr_[_pID].gen;
        }

        eth_can_use = ((plyr_[_pID].win).add(plyr_[_pID].aff)).add(usedGen);

        plyr_[_pID].win = 0;
        plyr_[_pID].gen = 0;
        plyr_[_pID].aff = 0;
      }
      else
      {
        eth_can_use = (plyr_[_pID].win).add(plyr_[_pID].aff);
        plyr_[_pID].win = 0;
        plyr_[_pID].aff = 0;
      }

      return(eth_can_use);
  }

  
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _eth, SPCdatasets.EventReturns memory _eventData_)
        private
    {
		
        uint256 myrID = rID_;

        
        uint256 _now = now;

        uint256 eth_can_use = 0;

        
        if (_now > round_[myrID].strt + rndGap_ && (_now <= round_[myrID].end || (_now > round_[myrID].end && round_[myrID].plyr == 0)))
        {
            
            
            

            eth_can_use = genLimit(_pID);
            if(eth_can_use > 0)
            {
              
              core(myrID, _pID, eth_can_use, _affID, 2, _eventData_);
            }

        
        } else if (_now > round_[myrID].end && round_[myrID].ended == false) {
            
            round_[myrID].ended = true;
            _eventData_ = endRound(_eventData_);

            
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            
            emit SPCevents.onReLoadAndDistribute
            (
                msg.sender,
                plyr_[_pID].name,
                _eventData_.compressedData,
                _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.P3DAmount,
                _eventData_.genAmount
            );
        }
    }

    
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, SPCdatasets.EventReturns memory _eventData_)
        private
    {
        
        if (plyrRnds_[_pID][_rID].jionflag != 1)
        {
          _eventData_ = managePlayer(_pID, _eventData_);
          plyrRnds_[_pID][_rID].jionflag = 1;

          attend[round_[_rID].attendNum] = _pID;
          round_[_rID].attendNum  = (round_[_rID].attendNum).add(1);
        }

        if (_eth > 10000000000000000)
        {

            
            uint256 _keys = calckeys(_eth);

            
            if (_keys >= 1000000000000000000)
            {
              updateTimer(_keys, _rID);

              
              if (round_[_rID].plyr != _pID)
                round_[_rID].plyr = _pID;

              round_[_rID].team = 2;

              
              _eventData_.compressedData = _eventData_.compressedData + 100;
            }

            
            plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);

            
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndTmEth_[_rID][2] = _eth.add(rndTmEth_[_rID][2]);

            
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, 2, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, 2, _keys, _eventData_);

            
            endTx(_pID, 2, _eth, _keys, _eventData_);
        }
    }




    
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        uint256 temp;
        temp = (round_[_rIDlast].mask).mul((plyrRnds_[_pID][_rIDlast].keys)/1000000000000000000);
        if(temp > plyrRnds_[_pID][_rIDlast].mask)
        {
          return( temp.sub(plyrRnds_[_pID][_rIDlast].mask) );
        }
        else
        {
          return( 0 );
        }
    }

    
    function calcKeysReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        return ( calckeys(_eth) );
    }

    
    function iWantXKeys(uint256 _keys)
        public
        view
        returns(uint256)
    {
        return ( _keys/100 );
    }




    
    function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
        external
    {
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
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
        require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
        if(plyrNames_[_pID][_name] == false)
            plyrNames_[_pID][_name] = true;
    }

    
    function determinePID(SPCdatasets.EventReturns memory _eventData_)
        private
        returns (SPCdatasets.EventReturns)
    {
        uint256 _pID = pIDxAddr_[msg.sender];
        
        if (_pID == 0)
        {
            
            _pID = PlayerBook.getPlayerID(msg.sender);
            pID_ = _pID; 
            
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

    
    function managePlayer(uint256 _pID, SPCdatasets.EventReturns memory _eventData_)
        private
        returns (SPCdatasets.EventReturns)
    {
        uint256 temp_eth = 0;
        
        
        if (plyr_[_pID].lrnd != 0)
        {
          updateGenVault(_pID, plyr_[_pID].lrnd);
          temp_eth = ((plyr_[_pID].win).add((plyr_[_pID].gen))).add(plyr_[_pID].aff);

          plyr_[_pID].gen = 0;
          plyr_[_pID].aff = 0;
          plyr_[_pID].win = temp_eth;
        }

        
        plyr_[_pID].lrnd = rID_;

        
        _eventData_.compressedData = _eventData_.compressedData + 10;

        return(_eventData_);
    }

    
    function endRound(SPCdatasets.EventReturns memory _eventData_)
        private
        returns (SPCdatasets.EventReturns)
    {
        
        uint256 _rID = rID_;

        
        uint256 _winPID = round_[_rID].plyr;
        uint256 _winTID = round_[_rID].team;

        
        uint256 _pot = round_[_rID].pot;

        
        
        uint256 _win = (_pot.mul(30)) / 100;
        uint256 _com = (_pot / 10);
        uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
        uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
        uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);

        
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
        uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
        if (_dust > 0)
        {
            _gen = _gen.sub(_dust);
        }

        
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);

        
        _com = _com.add(_p3d.sub(_p3d / 2));
        admin.transfer(_com);

        _res = _res.add(_p3d / 2);

        
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = plyr_[_winPID].name;
        _eventData_.amountWon = _win;
        _eventData_.genAmount = _gen;
        _eventData_.P3DAmount = _p3d;
        _eventData_.newPot = _res;

        
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_).add(rndGap_);
        round_[_rID].pot = _res;

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

    
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, SPCdatasets.EventReturns memory _eventData_)
        private
        returns(SPCdatasets.EventReturns)
    {
        
        uint256 _p3d = (_eth/100).mul(3);
              
        
        
        uint256 _aff_cent = (_eth) / 100;
        
        uint256 tempID  = _affID;

        
        
        
        
        if (tempID != _pID && plyr_[tempID].name != '') 
        { 
            plyr_[tempID].aff = (_aff_cent.mul(5)).add(plyr_[tempID].aff);
            emit SPCevents.onAffiliatePayout(tempID, plyr_[tempID].addr, plyr_[tempID].name, _rID, _pID, _aff_cent.mul(5), now);
        } 
        else 
        {
            _p3d = _p3d.add(_aff_cent.mul(5));
        }

        tempID = PlayerBook.getPlayerID(plyr_[tempID].addr);
        tempID = PlayerBook.getPlayerLAff(tempID);

        if (tempID != _pID && plyr_[tempID].name != '') 
        { 
            plyr_[tempID].aff = (_aff_cent.mul(3)).add(plyr_[tempID].aff);
            emit SPCevents.onAffiliatePayout(tempID, plyr_[tempID].addr, plyr_[tempID].name, _rID, _pID, _aff_cent.mul(3), now);
        } 
        else 
        {
            _p3d = _p3d.add(_aff_cent.mul(3));
        }
        
        tempID = PlayerBook.getPlayerID(plyr_[tempID].addr);
        tempID = PlayerBook.getPlayerLAff(tempID);

        if (tempID != _pID && plyr_[tempID].name != '') 
        { 
            plyr_[tempID].aff = (_aff_cent.mul(2)).add(plyr_[tempID].aff);
            emit SPCevents.onAffiliatePayout(tempID, plyr_[tempID].addr, plyr_[tempID].name, _rID, _pID, _aff_cent.mul(2), now);
        } 
        else 
        {
            _p3d = _p3d.add(_aff_cent.mul(2));
        }


        
        _p3d = _p3d.add((_eth.mul(fees_[2].p3d)) / (100));
        if (_p3d > 0)
        {
            admin.transfer(_p3d);
            
            _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
        }

        return(_eventData_);
    }

  
    function potSwap()
        external
        payable
    {
        
        uint256 _rID = rID_ + 1;

        round_[_rID].pot = round_[_rID].pot.add(msg.value);
        emit SPCevents.onPotSwapDeposit(_rID, msg.value);
    }

    
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, SPCdatasets.EventReturns memory _eventData_)
        private
        returns(SPCdatasets.EventReturns)
    {
        
        uint256 _gen = (_eth.mul(fees_[2].gen)) / 100;

        
        uint256 _pot = (_eth.mul(5)) / 100;

        
        
        uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
        if (_dust > 0)
            _gen = _gen.sub(_dust);

        
        round_[_rID].pot = _pot.add(round_[_rID].pot);

        
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

  
    function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, SPCdatasets.EventReturns memory _eventData_)
        private
    {
    _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (2 * 100000000000000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);

        emit SPCevents.onEndTx
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
            _eventData_.P3DAmount,
            _eventData_.genAmount,
            _eventData_.potAmount,
            airDropPot_
        );
    }




    
    bool public activated_ = false;

    
    uint256 public pre_active_time = now + 600 seconds;
    
    
    function getRunInfo() public view returns(bool, uint256, uint256)
    {
        return
        (
            activated_,      
            pre_active_time, 
            now          
        );
    }

    function setPreActiveTime(uint256 _pre_time) public
    {
        
        require(msg.sender == admin, "only admin can activate"); 
        pre_active_time = _pre_time;
    }

    function activate()
        public
    {
        
        require(msg.sender == admin, "only admin can activate"); 

        
        require(activated_ == false, "SuperCard already activated");

        
        activated_ = true;
        

        
        rID_ = 1;
        round_[1].strt = now + rndExtra_ - rndGap_;
        round_[1].end = now + rndInit_ + rndExtra_;
    }

	





  function calckeys(uint256 _eth)
        pure
    public
        returns(uint256)
    {
        return ( (_eth).mul(100) );
    }

    
    function calceth(uint256 _keys)
        pure
    public
        returns(uint256)
    {
        return( (_keys)/100 );
    } 
	
	function clearKeys(uint256 num)
        public
    {
		
        uint256 myrID = rID_;

        uint256 number = num;
        if(num == 1)
        {
          number = 10000;
        }

        uint256 over_gen;
        uint256 cleared = 0;
        uint256 checkID;
        uint256 upperLimit;
        uint256 i;
        for(i = 0; i< round_[myrID].attendNum; i++)
        {
          checkID = attend[i];

          updateGenVault(checkID, plyr_[checkID].lrnd);

          if (plyr_[checkID].gen > 0)
          {
            upperLimit = ((plyrRnds_[checkID][myrID].keys).mul(105))/10000;
            if(plyr_[checkID].gen >= upperLimit)
            {
              over_gen = (plyr_[checkID].gen).sub(upperLimit);

              cleared = cleared.add(plyrRnds_[checkID][myrID].keys);

              round_[myrID].keys = (round_[myrID].keys).sub(plyrRnds_[checkID][myrID].keys);
              plyrRnds_[checkID][myrID].keys = 0;

              round_[myrID].pot = (round_[myrID].pot).add(over_gen);

			  plyr_[checkID].win = ((plyr_[checkID].win).add(upperLimit));
			  plyr_[checkID].gen = 0;

			  if(cleared >= number)
				  break;
            }
          }
        }
    }
 
    
    function calcInvalidKeys(uint256 _rID,uint256 _pID) 
      private 
      returns(uint256)
    {
      uint256 InvalidKeys = 0; 
      uint256 upperLimit = 0;

      updateGenVault(_pID, plyr_[_pID].lrnd);
      if (plyr_[_pID].gen > 0)
      {
        upperLimit = ((plyrRnds_[_pID][_rID].keys).mul(105))/10000;
        if(plyr_[_pID].gen >= upperLimit)
        {
          InvalidKeys = InvalidKeys.add(plyrRnds_[_pID][_rID].keys);
        }
      }

      return(InvalidKeys);
    }

    
	function getInvalidKeys() public view returns(uint256,uint256,uint256)
    {
        uint256 LastRID = rID_;
        uint256 LastPID = pID_;
        
        uint256 _rID = 0;
        uint256 _pID = 0;
        uint256 InvalidKeys = 0;
        uint256 TotalKeys = 0;
        
        for( _rID = 1 ; _rID <= LastRID ; _rID++)
        {
          TotalKeys = TotalKeys.add(round_[_rID].keys);
          for( _pID = 1 ; _pID <= LastPID ; _pID++)
          {
            InvalidKeys = InvalidKeys.add(calcInvalidKeys(_rID,_pID));
          }
        }
        
        return
        (
            InvalidKeys, 
            TotalKeys,   
            now          
        );
    } 	
}





library SPCdatasets {
    
    
        
        
        
        
        
        
        
        
        
        
        
        
    
    
        
        
        
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         
        bytes32 winnerName;         
        uint256 amountWon;          
        uint256 newPot;             
        uint256 P3DAmount;          
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
    uint256 jionflag;   
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
    uint256 attendNum; 
    }
    struct TeamFee {
        uint256 gen;    
        uint256 p3d;    
    }
    struct PotSplit {
        uint256 gen;    
        uint256 p3d;    
    }
}






interface PlayerBookInterface {
    function getPlayerID(address _addr) external returns (uint256);
    function getPlayerName(uint256 _pID) external view returns (bytes32);
    function getPlayerLAff(uint256 _pID) external view returns (uint256);
    function getPlayerAddr(uint256 _pID) external view returns (address);
    function getNameFee() external view returns (uint256);
    function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
    function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
}



library NameFilter {
    
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        
        bool _hasNonNumber;

        
        for (uint256 i = 0; i < _length; i++)
        {
            
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                
                _temp[i] = byte(uint(_temp[i]) + 32);

                
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    
                    _temp[i] == 0x20 ||
                    
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}


library SafeMath {

    
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
}