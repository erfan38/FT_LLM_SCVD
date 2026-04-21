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

contract RC_KYC is AtomaxKycInterface, AtomaxKyc {
    using SafeMath for uint256;
    
    TokedoDaico tokenSaleContract;
    
    uint256 public startTime;
    uint256 public endTime;
    
    uint256 public etherMinimum;
    uint256 public soldTokens;
    uint256 public remainingTokens;
    uint256 public tokenPrice;
	
	mapping(address => uint256) public etherUser; 
	mapping(address => uint256) public pendingTokenUser; 
	mapping(address => uint256) public tokenUser; 
	
    constructor(address _tokenSaleContract, uint256 _tokenPrice, uint256 _remainingTokens, uint256 _etherMinimum, uint256 _startTime , uint256 _endTime) public {
        require ( _tokenSaleContract != address(0), "_tokenSaleContract != address(0)" );
        require ( _tokenPrice != 0, "_tokenPrice != 0" );
        require ( _remainingTokens != 0, "_remainingTokens != 0" );  
        require ( _startTime != 0, "_startTime != 0" );
        require ( _endTime != 0, "_endTime != 0" );
        
        tokenSaleContract = TokedoDaico(_tokenSaleContract);
        
        soldTokens = 0;
        remainingTokens = _remainingTokens;
        tokenPrice = _tokenPrice;
        etherMinimum = _etherMinimum;
        
        startTime = _startTime;
        endTime = _endTime;
    }
    
    modifier onlyTokenSaleOwner() {
        require(msg.sender == tokenSaleContract.owner() );
        _;
    }
    
    function setTime(uint256 _newStart, uint256 _newEnd) public onlyTokenSaleOwner {
        if ( _newStart != 0 ) startTime = _newStart;
        if ( _newEnd != 0 ) endTime = _newEnd;
    }
    
    function changeMinimum(uint256 _newEtherMinimum) public onlyTokenSaleOwner {
        etherMinimum = _newEtherMinimum;
    }
    
    function releaseTokensTo(address buyer) internal returns(bool) {
        if( msg.value > 0 ) takeEther(buyer);
        giveToken(buyer);
        return true;
    }
    
    function started() public view returns(bool) {
        return now > startTime || remainingTokens == 0;
    }
    
    function ended() public view returns(bool) {
        return now > endTime || remainingTokens == 0;
    }
    
    function startTime() public view returns(uint) {
        return startTime;
    }
    
    function endTime() public view returns(uint) {
        return endTime;
    }
    
    function totalTokens() public view returns(uint) {
        return remainingTokens.add(soldTokens);
    }
    
    function remainingTokens() public view returns(uint) {
        return remainingTokens;
    }
    
    function price() public view returns(uint) {
        return uint256(1 ether).div( tokenPrice ).mul( 10 ** uint256(tokenSaleContract.decimals()) );
    }
	
	function () public payable{
	    takeEther(msg.sender);
	}
	
	event TakeEther(address buyer, uint256 value, uint256 soldToken, uint256 tokenPrice );
	
	function takeEther(address _buyer) internal {
	    require( now > startTime, "now > startTime" );
		require( now < endTime, "now < endTime");
        require( msg.value >= etherMinimum, "msg.value >= etherMinimum"); 
        require( remainingTokens > 0, "remainingTokens > 0" );
        
        uint256 oneToken = 10 ** uint256(tokenSaleContract.decimals());
        uint256 tokenAmount = msg.value.mul( oneToken ).div( tokenPrice );
        
        uint256 remainingTokensGlobal = tokenInterface( tokenSaleContract.tokenContract() ).balanceOf( address(tokenSaleContract) );
        
        uint256 remainingTokensApplied;
        if ( remainingTokensGlobal > remainingTokens ) { 
            remainingTokensApplied = remainingTokens;
        } else {
            remainingTokensApplied = remainingTokensGlobal;
        }
        
        uint256 refund = 0;
        if ( remainingTokensApplied < tokenAmount ) {
            refund = (tokenAmount - remainingTokensApplied).mul(tokenPrice).div(oneToken);
            tokenAmount = remainingTokensApplied;
			remainingTokens = 0; 
            _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount); 
        }
        
        etherUser[_buyer] = etherUser[_buyer].add(msg.value.sub(refund));
        pendingTokenUser[_buyer] = pendingTokenUser[_buyer].add(tokenAmount);	
        
        emit TakeEther( _buyer, msg.value, tokenAmount, tokenPrice );
	}
	
	function giveToken(address _buyer) internal {
	    require( pendingTokenUser[_buyer] > 0, "pendingTokenUser[_buyer] > 0" );

		tokenUser[_buyer] = tokenUser[_buyer].add(pendingTokenUser[_buyer]);
	
		tokenSaleContract.sendTokens(_buyer, pendingTokenUser[_buyer]);
		soldTokens = soldTokens.add(pendingTokenUser[_buyer]);
		pendingTokenUser[_buyer] = 0;
		
		require( address(tokenSaleContract).call.value( etherUser[_buyer] )( bytes4( keccak256("forwardEther()") ) ) );
		etherUser[_buyer] = 0;
	}

    function refundEther(address to) public onlyTokenSaleOwner {
        to.transfer(etherUser[to]);
        etherUser[to] = 0;
        pendingTokenUser[to] = 0;
    }
    
    function withdraw(address to, uint256 value) public onlyTokenSaleOwner { 
        to.transfer(value);
    }
	
	function userBalance(address _user) public view returns( uint256 _pendingTokenUser, uint256 _tokenUser, uint256 _etherUser ) {
		return (pendingTokenUser[_user], tokenUser[_user], etherUser[_user]);
	}
}
