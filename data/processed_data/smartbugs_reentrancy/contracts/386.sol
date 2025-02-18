pragma solidity ^0.4.23;

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    return a / b;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract SatisfactionToken is ERC20, CheckpointStorage, NoOwner {

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Burn(address indexed burner, uint256 value);

  using SafeMath for uint256;

  string public name = "Satisfaction Token";
  uint8 public decimals = 18;
  string public symbol = "SAT";
  string public version;

  



  SatisfactionToken public parentToken;

  



  uint256 public parentSnapShotBlock;

  
  uint256 public creationBlock;

  




  mapping(address => Checkpoint[]) internal balances;

  
  mapping(address => mapping(address => uint256)) internal allowed;

  
  bool public transfersEnabled;

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  constructor(
    address _parentToken,
    uint256 _parentSnapShotBlock,
    string _tokenVersion,
    bool _transfersEnabled) public
  {
    version = _tokenVersion;
    parentToken = SatisfactionToken(_parentToken);
    parentSnapShotBlock = _parentSnapShotBlock;
    transfersEnabled = _transfersEnabled;
    creationBlock = block.number;
  }

  





  function transfer(address _to, uint256 _value) public returns (bool) {
    require(transfersEnabled);
    require(parentSnapShotBlock < block.number);
    require(_to != address(0));

    uint256 lastBalance = balanceOfAt(msg.sender, block.number);
    require(_value <= lastBalance);

    return doTransfer(msg.sender, _to, _value, lastBalance);
  }

  









  function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
    require(_to != address(this));

    transfer(_to, _value);

    
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  






  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(transfersEnabled);
    require(parentSnapShotBlock < block.number);
    require(_to != address(0));
    require(_value <= allowed[_from][msg.sender]);

    uint256 lastBalance = balanceOfAt(_from, block.number);
    require(_value <= lastBalance);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    return doTransfer(_from, _to, _value, lastBalance);
  }

  










  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
    public payable returns (bool)
  {
    require(_to != address(this));

    transferFrom(_from, _to, _value);

    
    require(_to.call.value(msg.value)(_data));
    return true;
  }

  










  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  






  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  










  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  












  function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
    require(_spender != address(this));

    increaseApproval(_spender, _addedValue);

    
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  










  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  












  function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
    require(_spender != address(this));

    decreaseApproval(_spender, _subtractedValue);

    
    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  



  function balanceOf(address _owner) public view returns (uint256) {
    return balanceOfAt(_owner, block.number);
  }

  






  function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {
    
    
    
    
    
    if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
      if (address(parentToken) != address(0)) {
        return parentToken.balanceOfAt(_owner, Math.min256(_blockNumber, parentSnapShotBlock));
      } else {
        
        return 0;
      }
    
    } else {
      return getValueAt(balances[_owner], _blockNumber);
    }
  }

  




  function totalSupply() public view returns (uint256) {
    return totalSupplyAt(block.number);
  }

  





  function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {

    
    
    
    
    
    if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
      if (address(parentToken) != 0) {
        return parentToken.totalSupplyAt(Math.min256(_blockNumber, parentSnapShotBlock));
      } else {
        return 0;
      }
    
    } else {
      return getValueAt(totalSupplyHistory, _blockNumber);
    }
  }

  






  function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
    uint256 curTotalSupply = totalSupply();
    uint256 lastBalance = balanceOf(_to);

    updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));
    updateValueAtNow(balances[_to], lastBalance.add(_amount));

    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  




  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

  




  function burn(uint256 _value) public {
    uint256 lastBalance = balanceOf(msg.sender);
    require(_value <= lastBalance);

    address burner = msg.sender;
    uint256 curTotalSupply = totalSupply();

    updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
    updateValueAtNow(balances[burner], lastBalance.sub(_value));

    emit Burn(burner, _value);
  }

  





  function burnFrom(address _from, uint256 _value) public {
    require(_value <= allowed[_from][msg.sender]);

    uint256 lastBalance = balanceOfAt(_from, block.number);
    require(_value <= lastBalance);

    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    address burner = _from;
    uint256 curTotalSupply = totalSupply();

    updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
    updateValueAtNow(balances[burner], lastBalance.sub(_value));

    emit Burn(burner, _value);
  }

  




  function enableTransfers(bool _transfersEnabled) public onlyOwner canMint {
    transfersEnabled = _transfersEnabled;
  }

  









  function doTransfer(address _from, address _to, uint256 _value, uint256 _lastBalance) internal returns (bool) {
    if (_value == 0) {
      return true;
    }

    updateValueAtNow(balances[_from], _lastBalance.sub(_value));

    uint256 previousBalance = balanceOfAt(_to, block.number);
    updateValueAtNow(balances[_to], previousBalance.add(_value));

    emit Transfer(_from, _to, _value);
    return true;
  }
}