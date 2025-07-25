





pragma solidity ^0.4.24;



library SafeMath {
  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    
    uint c = a / b;
    
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}



library ZethrTierLibrary {
  uint constant internal magnitude = 2 ** 64;

  
  
  function getTier(uint divRate) internal pure returns (uint8) {

    
    
    uint actualDiv = divRate / magnitude;
    if (actualDiv >= 30) {
      return 6;
    } else if (actualDiv >= 25) {
      return 5;
    } else if (actualDiv >= 20) {
      return 4;
    } else if (actualDiv >= 15) {
      return 3;
    } else if (actualDiv >= 10) {
      return 2;
    } else if (actualDiv >= 5) {
      return 1;
    } else if (actualDiv >= 2) {
      return 0;
    } else {
      
      revert();
    }
  }

  function getDivRate(uint _tier)
  internal pure
  returns (uint8)
  {
    if (_tier == 0) {
      return 2;
    } else if (_tier == 1) {
      return 5;
    } else if (_tier == 2) {
      return 10;
    } else if (_tier == 3) {
      return 15;
    } else if (_tier == 4) {
      return 20;
    } else if (_tier == 5) {
      return 25;
    } else if (_tier == 6) {
      return 33;
    } else {
      revert();
    }
  }
}



contract ZethrMultiSigWallet is ERC223Receiving {
  using SafeMath for uint;

  



  event Confirmation(address indexed sender, uint indexed transactionId);
  event Revocation(address indexed sender, uint indexed transactionId);
  event Submission(uint indexed transactionId);
  event Execution(uint indexed transactionId);
  event ExecutionFailure(uint indexed transactionId);
  event Deposit(address indexed sender, uint value);
  event OwnerAddition(address indexed owner);
  event OwnerRemoval(address indexed owner);
  event WhiteListAddition(address indexed contractAddress);
  event WhiteListRemoval(address indexed contractAddress);
  event RequirementChange(uint required);
  event BankrollInvest(uint amountReceived);

  



  mapping (uint => Transaction) public transactions;
  mapping (uint => mapping (address => bool)) public confirmations;
  mapping (address => bool) public isOwner;
  address[] public owners;
  uint public required;
  uint public transactionCount;
  bool internal reEntered = false;
  uint constant public MAX_OWNER_COUNT = 15;

  



  struct Transaction {
    address destination;
    uint value;
    bytes data;
    bool executed;
  }

  struct TKN {
    address sender;
    uint value;
  }

  



  modifier onlyWallet() {
    if (msg.sender != address(this))
      revert();
    _;
  }

  modifier isAnOwner() {
    address caller = msg.sender;
    if (isOwner[caller])
      _;
    else
      revert();
  }

  modifier ownerDoesNotExist(address owner) {
    if (isOwner[owner]) 
      revert();
      _;
  }

  modifier ownerExists(address owner) {
    if (!isOwner[owner])
      revert();
    _;
  }

  modifier transactionExists(uint transactionId) {
    if (transactions[transactionId].destination == 0)
      revert();
    _;
  }

  modifier confirmed(uint transactionId, address owner) {
    if (!confirmations[transactionId][owner])
      revert();
    _;
  }

  modifier notConfirmed(uint transactionId, address owner) {
    if (confirmations[transactionId][owner])
      revert();
    _;
  }

  modifier notExecuted(uint transactionId) {
    if (transactions[transactionId].executed)
      revert();
    _;
  }

  modifier notNull(address _address) {
    if (_address == 0)
      revert();
    _;
  }

  modifier validRequirement(uint ownerCount, uint _required) {
    if ( ownerCount > MAX_OWNER_COUNT
      || _required > ownerCount
      || _required == 0
      || ownerCount == 0)
      revert();
    _;
  }


  



  
  
  
  constructor (address[] _owners, uint _required)
    public
    validRequirement(_owners.length, _required)
  {
    
    for (uint i=0; i<_owners.length; i++) {
      if (isOwner[_owners[i]] || _owners[i] == 0)
        revert();
      isOwner[_owners[i]] = true;
    }

    
    owners = _owners;

    
    required = _required;
  }

  










  
  function()
    public
    payable
  {

  }
    
  
  
  function addOwner(address owner)
    public
    onlyWallet
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required)
  {
    isOwner[owner] = true;
    owners.push(owner);
    emit OwnerAddition(owner);
  }

  
  
  function removeOwner(address owner)
    public
    onlyWallet
    ownerExists(owner)
    validRequirement(owners.length, required)
  {
    isOwner[owner] = false;
    for (uint i=0; i<owners.length - 1; i++)
      if (owners[i] == owner) {
        owners[i] = owners[owners.length - 1];
        break;
      }

    owners.length -= 1;
    if (required > owners.length)
      changeRequirement(owners.length);
    emit OwnerRemoval(owner);
  }

  
  
  
  function replaceOwner(address owner, address newOwner)
    public
    onlyWallet
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
  {
    for (uint i=0; i<owners.length; i++)
      if (owners[i] == owner) {
        owners[i] = newOwner;
        break;
      }

    isOwner[owner] = false;
    isOwner[newOwner] = true;
    emit OwnerRemoval(owner);
    emit OwnerAddition(newOwner);
  }

  
  
  function changeRequirement(uint _required)
    public
    onlyWallet
    validRequirement(owners.length, _required)
  {
    required = _required;
    emit RequirementChange(_required);
  }

  
  
  
  
  
  function submitTransaction(address destination, uint value, bytes data)
    public
    returns (uint transactionId)
  {
    transactionId = addTransaction(destination, value, data);
    confirmTransaction(transactionId);
  }

  
  
  function confirmTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
  {
    confirmations[transactionId][msg.sender] = true;
    emit Confirmation(msg.sender, transactionId);
    executeTransaction(transactionId);
  }

  
  
  function revokeConfirmation(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
  {
    confirmations[transactionId][msg.sender] = false;
    emit Revocation(msg.sender, transactionId);
  }

  
  
  function executeTransaction(uint transactionId)
    public
    notExecuted(transactionId)
  {
    if (isConfirmed(transactionId)) {
      Transaction storage txToExecute = transactions[transactionId];
      txToExecute.executed = true;
      if (txToExecute.destination.call.value(txToExecute.value)(txToExecute.data))
        emit Execution(transactionId);
      else {
        emit ExecutionFailure(transactionId);
        txToExecute.executed = false;
      }
    }
  }

  
  
  
  function isConfirmed(uint transactionId)
    public
    constant
    returns (bool)
  {
    uint count = 0;
    for (uint i=0; i<owners.length; i++) {
      if (confirmations[transactionId][owners[i]])
        count += 1;
      if (count == required)
        return true;
    }
  }

  



  
  
  
  
  
  function addTransaction(address destination, uint value, bytes data)
    internal
    notNull(destination)
    returns (uint transactionId)
  {
    transactionId = transactionCount;

    transactions[transactionId] = Transaction({
        destination: destination,
        value: value,
        data: data,
        executed: false
    });

    transactionCount += 1;
    emit Submission(transactionId);
  }

  


  
  
  
  function getConfirmationCount(uint transactionId)
    public
    constant
    returns (uint count)
  {
    for (uint i=0; i<owners.length; i++)
      if (confirmations[transactionId][owners[i]])
        count += 1;
  }

  
  
  
  
  function getTransactionCount(bool pending, bool executed)
    public
    constant
    returns (uint count)
  {
    for (uint i=0; i<transactionCount; i++)
      if (pending && !transactions[i].executed || executed && transactions[i].executed)
        count += 1;
  }

  
  
  function getOwners()
    public
    constant
    returns (address[])
  {
    return owners;
  }

  
  
  
  function getConfirmations(uint transactionId)
    public
    constant
    returns (address[] _confirmations)
  {
    address[] memory confirmationsTemp = new address[](owners.length);
    uint count = 0;
    uint i;
    for (i=0; i<owners.length; i++)
      if (confirmations[transactionId][owners[i]]) {
        confirmationsTemp[count] = owners[i];
        count += 1;
      }

      _confirmations = new address[](count);

      for (i=0; i<count; i++)
        _confirmations[i] = confirmationsTemp[i];
  }

  
  
  
  
  
  
  function getTransactionIds(uint from, uint to, bool pending, bool executed)
    public
    constant
    returns (uint[] _transactionIds)
  {
    uint[] memory transactionIdsTemp = new uint[](transactionCount);
    uint count = 0;
    uint i;

    for (i=0; i<transactionCount; i++)
      if (pending && !transactions[i].executed || executed && transactions[i].executed) {
        transactionIdsTemp[count] = i;
        count += 1;
      }

      _transactionIds = new uint[](to - from);

    for (i=from; i<to; i++)
      _transactionIds[i - from] = transactionIdsTemp[i];
  }

  function tokenFallback(address , uint , bytes )
  public
  returns (bool)
  {
    return true;
  }
}



