pragma solidity ^0.4.24;

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

contract TokedoDaico is Ownable {
    using SafeMath for uint256;
    
    tokenInterface public tokenContract;
    
    address public milestoneSystem;
	uint256 public decimals;
    uint256 public tokenPrice;

    mapping(address => bool) public rc;

    constructor(address _wallet, address _tokenAddress, uint256[] _time, uint256[] _funds, uint256 _tokenPrice, uint256 _activeSupply) public {
        tokenContract = tokenInterface(_tokenAddress);
        decimals = tokenContract.decimals();
        tokenPrice = _tokenPrice;
        milestoneSystem = new MilestoneSystem(_wallet,_tokenAddress, _time, _funds, _tokenPrice, _activeSupply);
    }
    
    modifier onlyRC() {
        require( rc[msg.sender], "rc[msg.sender]" ); 
        _;
    }
    
    function forwardEther() onlyRC payable public returns(bool) {
        require(milestoneSystem.call.value(msg.value)(), "wallet.call.value(msg.value)()");
        return true;
    }
    
	function sendTokens(address _buyer, uint256 _amount) onlyRC public returns(bool) {
        return tokenContract.transfer(_buyer, _amount);
    }

    event NewRC(address contr);
    
    function addRC(address _rc) onlyOwner public {
        rc[ _rc ]  = true;
        emit NewRC(_rc);
    }
    
    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }
    
    function setTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = tokenInterface(_tokenContract);
    }
}
