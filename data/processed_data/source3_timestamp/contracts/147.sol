contract FsTKColdWallet {
  using Math for uint256;

  event ConfirmationNeeded(address indexed initiator, bytes32 indexed operation, address indexed to, uint256 value, bytes data);
  event Confirmation(address indexed authority, bytes32 indexed operation);
  event Revoke(address indexed authority, bytes32 indexed operation);

  event AuthorityChanged(address indexed oldAuthority, address indexed newAuthority);
  event AuthorityAdded(address authority);
  event AuthorityRemoved(address authority);

  event RequirementChanged(uint256 required);
  event DayLimitChanged(uint256 dayLimit);
  event SpentTodayReset(uint256 spentToday);

  event Deposit(address indexed from, uint256 value);
  event SingleTransaction(address indexed authority, address indexed to, uint256 value, bytes data, address created);
  event MultiTransaction(address indexed authority, bytes32 indexed operation, address indexed to, uint256 value, bytes data, address created);

  struct TransactionInfo {
    address to;
    uint256 value;
    bytes data;
  }

  struct PendingTransactionState {
    TransactionInfo info;
    uint256 confirmNeeded;
    uint256 confirmBitmap;
    uint256 index;
  }

  modifier onlyAuthority {
    require(isAuthority(msg.sender));
    _;
  }

  modifier confirmAndRun(bytes32 operation) {
    if (confirmAndCheck(operation)) {
      _;
    }
  }

  uint256 constant MAX_AUTHORITIES = 250;

  uint256 public requiredAuthorities;
  uint256 public numAuthorities;

  uint256 public dailyLimit;
  uint256 public spentToday;
  uint256 public lastDay;

  address[256] public authorities;
  mapping(address => uint256) public authorityIndex;
  mapping(bytes32 => PendingTransactionState) public pendingTransaction;
  bytes32[] public pendingOperation;

  constructor(address[] _authorities, uint256 required, uint256 _daylimit) public {
    require(
      required > 0 &&
      authorities.length >= required
    );

    numAuthorities = _authorities.length;
    for (uint256 i = 0; i < _authorities.length; i += 1) {
      authorities[1 + i] = _authorities[i];
      authorityIndex[_authorities[i]] = 1 + i;
    }

    requiredAuthorities = required;

    dailyLimit = _daylimit;
    lastDay = today();
  }

  function() external payable {
    if (msg.value > 0) {
      emit Deposit(msg.sender, msg.value);
    }
  }

  function getAuthority(uint256 index) public view returns (address) {
    return authorities[index + 1];
  }

  function getAuthorityIndex(address authority) public view returns (uint256 index) {
    index = authorityIndex[authority];
    require(index > 0);
  }

  function isAuthority(address authority) public view returns (bool) {
    return authorityIndex[authority] > 0;
  }

  function hasConfirmed(bytes32 operation, address _address) public view returns (bool) {
    return (pendingTransaction[operation].confirmBitmap & (1 << getAuthorityIndex(_address))) != 0;
  }

  function changeAuthority(address from, address to) public confirmAndRun(keccak256(msg.data)) {
    require(!isAuthority(to));

    uint256 index = getAuthorityIndex(from);
    authorities[index] = to;
    authorityIndex[to] = index;
    delete authorityIndex[from];
    clearPending();

    emit AuthorityChanged(from, to);
  }

  function addAuthority(address authority) public confirmAndRun(keccak256(msg.data)) {
    require(!isAuthority(authority));
    if (numAuthorities >= MAX_AUTHORITIES) {
      reOrganizeAuthorities();
    }
    require(numAuthorities < MAX_AUTHORITIES);

    numAuthorities += 1;
    authorities[numAuthorities] = authority;
    authorityIndex[authority] = numAuthorities;
    clearPending();

    emit AuthorityAdded(authority);
  }

  function removeAuthority(address authority) public confirmAndRun(keccak256(msg.data)) {
    require(numAuthorities > requiredAuthorities);

    uint256 index = getAuthorityIndex(authority);
    delete authorities[index];
    delete authorityIndex[authority];
    clearPending();
    reOrganizeAuthorities();

    emit AuthorityRemoved(authority);
  }

  function setRequirement(uint256 required) public confirmAndRun(keccak256(msg.data)) {
    require(numAuthorities >= requiredAuthorities);
    clearPending();

    emit RequirementChanged(requiredAuthorities = required);
  }

  function setDailyLimit(uint256 _dailyLimit) public confirmAndRun(keccak256(msg.data)) {
    clearPending();

    emit DayLimitChanged(dailyLimit = _dailyLimit);
  }

  function resetSpentToday() public confirmAndRun(keccak256(msg.data)) {
    clearPending();

    emit SpentTodayReset(spentToday);
    delete spentToday;
  }

  function propose(
    address to,
    uint256 value,
    bytes data
  )
    public
    onlyAuthority
    returns (bytes32 operation)
  {
    if ((data.length == 0 && checkAndUpdateLimit(value)) || requiredAuthorities == 1) {
      emit SingleTransaction(msg.sender, to, value, data, execute0(to, value, data));
    } else {
      operation = keccak256(abi.encodePacked(msg.data, pendingOperation.length));
      PendingTransactionState storage status = pendingTransaction[operation];
      if (status.info.to == 0 && status.info.value == 0 && status.info.data.length == 0) {
        status.info = TransactionInfo({
          to: to,
          value: value,
          data: data
        });
      }

      if (!confirm(operation)) {
        emit ConfirmationNeeded(msg.sender, operation, to, value, data);
      }
    }
  }

  function revoke(bytes32 operation) public {
    uint256 confirmFlag = 1 << getAuthorityIndex(msg.sender);
    PendingTransactionState storage state = pendingTransaction[operation];
    if (state.confirmBitmap & confirmFlag > 0) {
      state.confirmNeeded += 1;
      state.confirmBitmap &= ~confirmFlag;
      emit Revoke(msg.sender, operation);
    }
  }

  function confirm(bytes32 operation) public confirmAndRun(operation) returns (bool) {
     PendingTransactionState storage status = pendingTransaction[operation];
    if (status.info.to != 0 || status.info.value != 0 || status.info.data.length != 0) {
      emit MultiTransaction(
        msg.sender,
        operation,
        status.info.to,
        status.info.value,
        status.info.data,
        execute0(status.info.to, status.info.value, status.info.data)
      );
      delete pendingTransaction[operation].info;

      return true;
    }
  }

  function execute0(
    address to,
    uint256 value,
    bytes data
  )
    private
    returns (address created)
  {
    if (to == 0) {
      created = create0(value, data);
    } else {
      require(to.call.value(value)(data));
    }
  }

  function create0(uint256 value, bytes code) internal returns (address _address) {
    assembly {
      _address := create(value, add(code, 0x20), mload(code))
      if iszero(extcodesize(_address)) {
        revert(0, 0)
      }
    }
  }

  function confirmAndCheck(bytes32 operation) private returns (bool) {
    PendingTransactionState storage pending = pendingTransaction[operation];
    if (pending.confirmNeeded == 0) {
      pending.confirmNeeded = requiredAuthorities;
      delete pending.confirmBitmap;
      pending.index = pendingOperation.length;
      pendingOperation.push(operation);
    }

    uint256 confirmFlag = 1 << getAuthorityIndex(msg.sender);

    if (pending.confirmBitmap & confirmFlag == 0) {
      emit Confirmation(msg.sender, operation);
      if (pending.confirmNeeded <= 1) {
        delete pendingOperation[pending.index];
        delete pending.confirmNeeded;
        delete pending.confirmBitmap;
        delete pending.index;
        return true;
      } else {
        pending.confirmNeeded -= 1;
        pending.confirmBitmap |= confirmFlag;
      }
    }
  }

  function checkAndUpdateLimit(uint256 value) private returns (bool) {
    if (today() > lastDay) {
      spentToday = 0;
      lastDay = today();
    }

    uint256 _spentToday = spentToday.add(value);
    if (_spentToday <= dailyLimit) {
      spentToday = _spentToday;
      return true;
    }
    return false;
  }

  function today() private view returns (uint256) {
    return block.timestamp / 1 days;
  }

  function reOrganizeAuthorities() private {
    uint256 free = 1;
    while (free < numAuthorities) {
      while (free < numAuthorities && authorities[free] != 0) {
        free += 1;
      }
      while (numAuthorities > 1 && authorities[numAuthorities] == 0) {
        numAuthorities -= 1;
      }
      if (free < numAuthorities && authorities[numAuthorities] != 0 && authorities[free] == 0) {
        authorities[free] = authorities[numAuthorities];
        authorityIndex[authorities[free]] = free;
        delete authorities[numAuthorities];
      }
    }
  }

  function clearPending() private {
    for (uint256 i = 0; i < pendingOperation.length; i += 1) {
      delete pendingTransaction[pendingOperation[i]];
    }
    delete pendingOperation;
  }

}