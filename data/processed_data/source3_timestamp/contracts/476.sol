contract Crowdsale {


  using SafeMath for uint256;

   
  GambioToken public token;

   
  uint256 public startTime;
  uint256 public endTime;

  uint256 public rate;

   
  address public wallet;

   
  uint256 public weiRaised;

  event TokenPurchase(address indexed beneficiary, uint256 indexed value, uint256 indexed amount, uint256 transactionId);

  constructor(
    uint256 _startTime,
    uint256 _endTime,
    uint256 _rate,
    address _wallet,
    uint256 _initialWeiRaised,
    uint256 _tokenCap) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_wallet != address(0));
    require(_rate > 0);
    require(_tokenCap > 0);

    token = new GambioToken(_wallet, _tokenCap);
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
    weiRaised = _initialWeiRaised;
  }

   
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }
}

 

 
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

 

 

pragma solidity ^0.4.23;






 
