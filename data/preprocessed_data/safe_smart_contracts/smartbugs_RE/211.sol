pragma solidity ^0.4.24;






library SafeMath {
  


  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    
    
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  


  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); 
    uint256 c = _a / _b;
    

    return c;
  }

  


  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  


  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}





library SafeERC20 {
  function safeTransfer(
    ERC20 _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

contract CrowdsaleWPTByAuction2 is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  
  ERC20 public token;

  
  address public wallet;

  
  Token public minterContract;

  
  uint256 public ethRaised;

  
  mapping (address => uint256) private _balances;

  
  address[] public beneficiaryAddresses;

  
  uint256 public cap;

  
  uint256 public bonusCap;

  
  uint256 public openingTime;
  uint256 public closingTime;

  
  uint public minInvestmentValue;

  
  bool public checksOn;

  
  uint256 public gasAmount;

  



  function setMinter(address _minterAddr) public onlyOwner {
    minterContract = Token(_minterAddr);
  }

  


  modifier onlyWhileOpen {
    
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  




  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  






  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
    );

  






  event TokensTransfer(
    address indexed _from,
    address indexed _to,
    uint256 amount,
    bool isDone
    );

constructor () public {
    wallet = 0xeA9cbceD36a092C596e9c18313536D0EEFacff46;
    openingTime = 1537135200;
    closingTime = 1538344800;
    cap = 0;
    bonusCap = 1000000000000000000000000; 
    minInvestmentValue = 0.02 ether;
    ethRaised = 0;
        
    checksOn = true;
    gasAmount = 25000;
  }

   


  function closeRound() public onlyOwner {
    closingTime = block.timestamp + 1;
  }

   


  function setToken(ERC20 _token) public onlyOwner {
    token = _token;
  }

   


  function setWallet(address _wallet) public onlyOwner {
    wallet = _wallet;
  }

   


  function changeMinInvest(uint256 newMinValue) public onlyOwner {
    minInvestmentValue = newMinValue;
  }

  


  function setChecksOn(bool _checksOn) public onlyOwner {
    checksOn = _checksOn;
  }

   


  function setGasAmount(uint256 _gasAmount) public onlyOwner {
    gasAmount = _gasAmount;
  }
  
   


  function setCap(uint256 _newCap) public onlyOwner {
    cap = _newCap;
  }

   


  function setBonusCap(uint256 _newBonusCap) public onlyOwner {
    bonusCap = _newBonusCap;
  }

   


  function addInvestor(address _beneficiary, uint8 amountOfinvestedEth) public onlyOwner {
      _balances[_beneficiary] = amountOfinvestedEth;
      beneficiaryAddresses.push(_beneficiary);
  }

  



  function hasClosed() public view returns (bool) {
    
    return block.timestamp > closingTime;
  }

  



  function hasOpened() public view returns (bool) {
    
    return (openingTime < block.timestamp && block.timestamp < closingTime);
  }

   


  function startNewRound(address _wallet, ERC20 _token, uint256 _cap, uint256 _bonusCap, uint256 _openingTime, uint256 _closingTime) payable public onlyOwner {
    require(!hasOpened());
    wallet = _wallet;
    token = _token;
    cap = _cap;
    bonusCap = _bonusCap;
    openingTime = _openingTime;
    closingTime = _closingTime;
    ethRaised = 0;
  }

   


  function payAllBonuses() payable public onlyOwner {
    require(hasClosed());

    uint256 allFunds = cap.add(bonusCap);
    uint256 priceWPTperETH = allFunds.div(ethRaised);

    uint beneficiaryCount = beneficiaryAddresses.length;
    for (uint i = 0; i < beneficiaryCount; i++) {
      minterContract.mint(beneficiaryAddresses[i], _balances[beneficiaryAddresses[i]].mul(priceWPTperETH));
      delete _balances[beneficiaryAddresses[i]];
    }

    delete beneficiaryAddresses;
    cap = 0;
    bonusCap = 0;

  }

  
  
  

  


  function () payable external {
    buyTokens(msg.sender);
  }

  



  function buyTokens(address _beneficiary) payable public{

    uint256 weiAmount = msg.value;
    if (checksOn) {
        _preValidatePurchase(_beneficiary, weiAmount);
    }

    _balances[_beneficiary] = _balances[_beneficiary].add(weiAmount);
    beneficiaryAddresses.push(_beneficiary);

    
    ethRaised = ethRaised.add(weiAmount);

    _forwardFunds();
  }

  




  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount)
  internal
  view
  onlyWhileOpen
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0 && _weiAmount > minInvestmentValue);
  }

  


  function _forwardFunds() internal {
    bool isTransferDone = wallet.call.value(msg.value).gas(gasAmount)();
    emit TokensTransfer (
        msg.sender,
        wallet,
        msg.value,
        isTransferDone
        );
  }
}


