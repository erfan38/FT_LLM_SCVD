pragma solidity ^0.4.23;



contract ShareStore is IRoleModel, IShareStore, IStateModel {
  
  using SafeMath for uint;
  
  


  uint public minimalDeposit;
  
  


  address public tokenAddress;
  
  


  mapping (address=>uint) public share;
  
  


  uint public totalShare;
  
  


  uint public totalToken;
  
  


  mapping (uint8=>uint) public stakeholderShare;
  mapping (address=>uint) internal etherReleased_;
  mapping (address=>uint) internal tokenReleased_;
  mapping (uint8=>uint) internal stakeholderEtherReleased_;
  uint constant DECIMAL_MULTIPLIER = 1e18;

  


  uint public tokenPrice;
  
  






  function () public payable {
    uint8 _state = getState_();
    if (_state == ST_RAISING){
      buyShare_(_state);
      return;
    }
    
    if (_state == ST_MONEY_BACK) {
      refundShare_(msg.sender, share[msg.sender]);
      if(msg.value > 0)
        msg.sender.transfer(msg.value);
      return;
    }
    
    if (_state == ST_TOKEN_DISTRIBUTION) {
      releaseEther_(msg.sender, getBalanceEtherOf_(msg.sender));
      releaseToken_(msg.sender, getBalanceTokenOf_(msg.sender));
      if(msg.value > 0)
        msg.sender.transfer(msg.value);
      return;
    }
    revert();
  }
  
  
  



  function buyShare() external payable returns(bool) {
    return buyShare_(getState_());
  }
  
  




  function acceptTokenFromICO(uint _value) external returns(bool) {
    return acceptTokenFromICO_(_value);
  }
  
  




  function getStakeholderBalanceOf(uint8 _for) external view returns(uint) {
    return getStakeholderBalanceOf_(_for);
  }
  
  




  function getBalanceEtherOf(address _for) external view returns(uint) {
    return getBalanceEtherOf_(_for);
  }
  
  




  function getBalanceTokenOf(address _for) external view returns(uint) {
    return getBalanceTokenOf_(_for);
  }
  
  




  function releaseEtherToStakeholder(uint _value) external returns(bool) {
    uint8 _state = getState_();
    uint8 _for = getRole_();
    require(!((_for == RL_ICO_MANAGER) && ((_state != ST_WAIT_FOR_ICO) || (tokenPrice > 0))));
    return releaseEtherToStakeholder_(_state, _for, _value);
  }
  
  





  function releaseEtherToStakeholderForce(uint8 _for, uint _value) external returns(bool) {
    uint8 _role = getRole_();
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    uint8 _state = getState_();
    require(!((_for == RL_ICO_MANAGER) && ((_state != ST_WAIT_FOR_ICO) || (tokenPrice > 0))));
    return releaseEtherToStakeholder_(_state, _for, _value);
  }
  
  




  function releaseEther(uint _value) external returns(bool) {
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    return releaseEther_(msg.sender, _value);
  }
  
  





  function releaseEtherForce(address _for, uint _value) external returns(bool) {
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    return releaseEther_(_for, _value);
  }

  





  function releaseEtherForceMulti(address[] _for, uint[] _value) external returns(bool) {
    uint _sz = _for.length;
    require(_value.length == _sz);
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    for (uint i = 0; i < _sz; i++){
      require(releaseEther_(_for[i], _value[i]));
    }
    return true;
  }
  
  




  function releaseToken(uint _value) external returns(bool) {
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    return releaseToken_(msg.sender, _value);
  }
  
  





  function releaseTokenForce(address _for, uint _value) external returns(bool) {
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    return releaseToken_(_for, _value);
  }


  





  function releaseTokenForceMulti(address[] _for, uint[] _value) external returns(bool) {
    uint _sz = _for.length;
    require(_value.length == _sz);
    uint8 _role = getRole_();
    uint8 _state = getState_();
    require(_state == ST_TOKEN_DISTRIBUTION);
    require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
    for(uint i = 0; i < _sz; i++){
      require(releaseToken_(_for[i], _value[i]));
    }
    return true;
  }
  
  




  function refundShare(uint _value) external returns(bool) {
    uint8 _state = getState_();
    require (_state == ST_MONEY_BACK);
    return refundShare_(msg.sender, _value);
  }
  
  





  function refundShareForce(address _for, uint _value) external returns(bool) {
    uint8 _state = getState_();
    uint8 _role = getRole_();
    require(_role == RL_ADMIN || _role == RL_PAYBOT);
    require (_state == ST_MONEY_BACK || _state == ST_RAISING);
    return refundShare_(_for, _value);
  }
  
  






  function execute(address _to, uint _value, bytes _data) external returns (bool) {
    require (getRole_()==RL_ADMIN);
    require (getState_()==ST_FUND_DEPRECATED);
    
    return _to.call.value(_value)(_data);
  }
  
  function getTotalShare_() internal view returns(uint){
    return totalShare;
  }

  function getEtherCollected_() internal view returns(uint){
    return totalShare;
  }

  function buyShare_(uint8 _state) internal returns(bool) {
    require(_state == ST_RAISING);
    require(msg.value >= minimalDeposit);
    uint _shareRemaining = getShareRemaining_();
    uint _shareAccept = (msg.value <= _shareRemaining) ? msg.value : _shareRemaining;

    share[msg.sender] = share[msg.sender].add(_shareAccept);
    totalShare = totalShare.add(_shareAccept);
    emit BuyShare(msg.sender, _shareAccept);
    if (msg.value!=_shareAccept) {
      msg.sender.transfer(msg.value.sub(_shareAccept));
    }
    return true;
  }

  function acceptTokenFromICO_(uint _value) internal returns(bool) {
    uint8 _state = getState_();
    uint8 _for = getRole_();
    require(_state == ST_WAIT_FOR_ICO);
    require(_for == RL_ICO_MANAGER);
    
    totalToken = totalToken.add(_value);
    emit AcceptTokenFromICO(msg.sender, _value);
    require(IERC20(tokenAddress).transferFrom(msg.sender, this, _value));
    if (tokenPrice > 0) {
      releaseEtherToStakeholder_(_state, _for, _value.mul(tokenPrice).div(DECIMAL_MULTIPLIER));
    }
    return true;
  }

  function getStakeholderBalanceOf_(uint8 _for) internal view returns (uint) {
    if (_for == RL_ICO_MANAGER) {
      return getEtherCollected_().mul(stakeholderShare[_for]).div(DECIMAL_MULTIPLIER).sub(stakeholderEtherReleased_[_for]);
    }

    if ((_for == RL_POOL_MANAGER) || (_for == RL_ADMIN)) {
      return stakeholderEtherReleased_[RL_ICO_MANAGER].mul(stakeholderShare[_for]).div(stakeholderShare[RL_ICO_MANAGER]);
    }
    return 0;
  }

  function releaseEtherToStakeholder_(uint8 _state, uint8 _for, uint _value) internal returns (bool) {
    require(_for != RL_DEFAULT);
    require(_for != RL_PAYBOT);
    require(!((_for == RL_ICO_MANAGER) && (_state != ST_WAIT_FOR_ICO)));
    uint _balance = getStakeholderBalanceOf_(_for);
    address _afor = getRoleAddress_(_for);
    require(_balance >= _value);
    stakeholderEtherReleased_[_for] = stakeholderEtherReleased_[_for].add(_value);
    emit ReleaseEtherToStakeholder(_for, _afor, _value);
    _afor.transfer(_value);
    return true;
  }

  function getBalanceEtherOf_(address _for) internal view returns (uint) {
    uint _stakeholderTotalEtherReserved = stakeholderEtherReleased_[RL_ICO_MANAGER]
    .mul(DECIMAL_MULTIPLIER).div(stakeholderShare[RL_ICO_MANAGER]);
    uint _restEther = getEtherCollected_().sub(_stakeholderTotalEtherReserved);
    return _restEther.mul(share[_for]).div(totalShare).sub(etherReleased_[_for]);
  }

  function getBalanceTokenOf_(address _for) internal view returns (uint) {
    return totalToken.mul(share[_for]).div(totalShare).sub(tokenReleased_[_for]);
  }

  function releaseEther_(address _for, uint _value) internal returns (bool) {
    uint _balance = getBalanceEtherOf_(_for);
    require(_balance >= _value);
    etherReleased_[_for] = etherReleased_[_for].add(_value);
    emit ReleaseEther(_for, _value);
    _for.transfer(_value);
    return true;
  }

  function releaseToken_( address _for, uint _value) internal returns (bool) {
    uint _balance = getBalanceTokenOf_(_for);
    require(_balance >= _value);
    tokenReleased_[_for] = tokenReleased_[_for].add(_value);
    emit ReleaseToken(_for, _value);
    require(IERC20(tokenAddress).transfer(_for, _value));
    return true;
  }

  function refundShare_(address _for, uint _value) internal returns(bool) {
    uint _balance = share[_for];
    require(_balance >= _value);
    share[_for] = _balance.sub(_value);
    totalShare = totalShare.sub(_value);
    emit RefundShare(_for, _value);
    _for.transfer(_value);
    return true;
  }
  
}


