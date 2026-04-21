pragma solidity ^0.4.0;






contract withAccounts is withOwners {
  uint defaultTimeoutPeriod = 2 days; 

  struct AccountTx {
    uint timeCreated;
    address user;
    uint amountHeld;
    uint amountSpent;
    uint8 state; 
  }

  uint public txCount = 0;
  mapping (uint => AccountTx) public accountTxs;
  

  


  uint public availableBalance = 0;
  uint public onholdBalance = 0;
  uint public spentBalance = 0; 

  mapping (address => uint) public availableBalances;
  mapping (address => uint) public onholdBalances;
  mapping (address => bool) public doNotAutoRefund;

  modifier handleDeposit {
    deposit(msg.sender, msg.value);
    _;
  }







  



  function depositFor(address _address) public payable {
    deposit(_address, msg.value);
  }

  



  function withdraw(uint _amount) public {
    if (_amount == 0) {
      _amount = availableBalances[msg.sender];
    }
    if (_amount > availableBalances[msg.sender]) {
      throw;
    }

    incrUserAvailBal(msg.sender, _amount, false);
    if (!msg.sender.call.value(_amount)()) {
      throw;
    }
  }

  




  function checkTimeout(uint _id) public {
    if (
      accountTxs[_id].state != 1 ||
      (now - accountTxs[_id].timeCreated) < defaultTimeoutPeriod
    ) {
      throw;
    }

    settle(_id, 0); 

    
    
  }

  






  function setDoNotAutoRefundTo(bool _option) public {
    doNotAutoRefund[msg.sender] = _option;
  }

  


  function updateDefaultTimeoutPeriod(uint _defaultTimeoutPeriod) public onlyOwners {
    if (_defaultTimeoutPeriod < 1 hours) {
      throw;
    }

    defaultTimeoutPeriod = _defaultTimeoutPeriod;
  }

  


  function collectRev() public onlyOwners {
    uint amount = spentBalance;
    spentBalance = 0;

    if (!msg.sender.call.value(amount)()) {
      throw;
    }
  }

  




  function returnFund(address _user, uint _amount) public onlyManagers {
    if (doNotAutoRefund[_user] || _amount > availableBalances[_user]) {
      throw;
    }
    if (_amount == 0) {
      _amount = availableBalances[_user];
    }

    incrUserAvailBal(_user, _amount, false);
    if (!_user.call.value(_amount)()) {
      throw;
    }
  }







  


  function deposit(address _user, uint _amount) internal {
    if (_amount > 0) {
      incrUserAvailBal(_user, _amount, true);
    }
  }

  


  function createTx(uint _id, address _user, uint _amount) internal {
    if (_amount > availableBalances[_user]) {
      throw;
    }

    accountTxs[_id] = AccountTx({
      timeCreated: now,
      user: _user,
      amountHeld: _amount,
      amountSpent: 0,
      state: 1 
    });

    incrUserAvailBal(_user, _amount, false);
    incrUserOnholdBal(_user, _amount, true);
  }

  function settle(uint _id, uint _amountSpent) internal {
    if (accountTxs[_id].state != 1 || _amountSpent > accountTxs[_id].amountHeld) {
      throw;
    }

    
    

    accountTxs[_id].amountSpent = _amountSpent;
    accountTxs[_id].state = 2; 

    spentBalance += _amountSpent;
    uint changeAmount = accountTxs[_id].amountHeld - _amountSpent;

    incrUserOnholdBal(accountTxs[_id].user, accountTxs[_id].amountHeld, false);
    incrUserAvailBal(accountTxs[_id].user, changeAmount, true);
  }

  function incrUserAvailBal(address _user, uint _by, bool _increase) internal {
    if (_increase) {
      availableBalances[_user] += _by;
      availableBalance += _by;
    } else {
      availableBalances[_user] -= _by;
      availableBalance -= _by;
    }
  }

  function incrUserOnholdBal(address _user, uint _by, bool _increase) internal {
    if (_increase) {
      onholdBalances[_user] += _by;
      onholdBalance += _by;
    } else {
      onholdBalances[_user] -= _by;
      onholdBalance -= _by;
    }
  }
}


