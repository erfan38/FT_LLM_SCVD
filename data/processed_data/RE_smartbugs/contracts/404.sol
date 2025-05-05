pragma solidity ^0.4.21;

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
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

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract A2ACrowdsale is ICrowdsaleProcessor {
    using SafeMath for uint256;
    
	event CROWDSALE_START(uint256 startTimestamp, uint256 endTimestamp, address fundingAddress);

	address public fundingAddress;
	address internal bountyAddress = 0x10945A93914aDb1D68b6eFaAa4A59DfB21Ba9951;
	
	A2AToken public token;
	
	mapping(address => bool) public partnerContracts;
	
	uint256 public icoPrice; 
	uint256 public icoBonus; 
	
	uint256 constant public wingsETHRewardsPercent = 2 * 10000; 
	uint256 constant public wingsTokenRewardsPercent = 2 * 10000; 
	uint256 public wingsETHRewards;
	uint256 public wingsTokenRewards;
	
	uint256 constant public maxTokensWithBonus = 500*(10**6)*(10**8);
	uint256 public bountyPercent;
		
	address[2] internal foundersAddresses = [
		0x2f072F00328B6176257C21E64925760990561001,
		0x2640d4b3baF3F6CF9bB5732Fe37fE1a9735a32CE
	];

	function A2ACrowdsale() public {
		owner = msg.sender;
		manager = msg.sender;
		icoPrice = 2000;
		icoBonus = 100 * 10000;
		wingsETHRewards = 0;
		wingsTokenRewards = 0;
		minimalGoal = 1000 ether;
		hardCap = 50000 ether;
		bountyPercent = 23 * 10000;
	}

	function mintETHRewards( address _contract, uint256 _amount ) public onlyManager() {
		require(_amount <= wingsETHRewards);
		require(_contract.call.value(_amount)());
		wingsETHRewards -= _amount;
	}
	
	function mintTokenRewards(address _contract, uint256 _amount) public onlyManager() {
		require( token != address(0) );
		require(_amount <= wingsTokenRewards);
		require( token.issueDuringICO(_contract, _amount) );
		wingsTokenRewards -= _amount;
	}

	function stop() public onlyManager() hasntStopped()	{
		stopped = true;
	}

	function start( uint256 _startTimestamp, uint256 _endTimestamp, address _fundingAddress ) public onlyManager() hasntStarted() hasntStopped() {
		require(_fundingAddress != address(0));
		require(_startTimestamp >= block.timestamp);
		require(_endTimestamp > _startTimestamp);
		duration = _endTimestamp - _startTimestamp;
		require(duration >= MIN_CROWDSALE_TIME && duration <= MAX_CROWDSALE_TIME);
		startTimestamp = _startTimestamp;
		endTimestamp = _endTimestamp;
		started = true;
		emit CROWDSALE_START(_startTimestamp, _endTimestamp, _fundingAddress);
	}

	
	function isFailed() public constant returns(bool) {
		return (
			
			started &&

			
			block.timestamp >= endTimestamp &&

			
			totalCollected < minimalGoal
		);
	}

	
	function isActive() public constant returns(bool) {
		return (
			
			started &&

			
			totalCollected < hardCap &&

			
			block.timestamp >= startTimestamp &&
			block.timestamp < endTimestamp
		);
	}

	
	function isSuccessful() public constant returns(bool) {
		return (
			
			totalCollected >= hardCap ||

			
			(block.timestamp >= endTimestamp && totalCollected >= minimalGoal)
		);
	}
	
	function setToken( A2AToken _token ) public onlyOwner() {
		token = _token;
	}
	
	function getToken() public returns(address) {
	    return address(token);
	}
	
	function setPrice( uint256 _icoPrice ) public onlyOwner() returns(bool) {
		icoPrice = _icoPrice;
		return true;
	}
	
	function setBonus( uint256 _icoBonus ) public onlyOwner() returns(bool) {
		icoBonus = _icoBonus;
		return true;
	}
	
	function setBountyAddress( address _bountyAddress ) public onlyOwner() returns(bool) {
		bountyAddress = _bountyAddress;
		return true;
	}
	
	function setBountyPercent( uint256 _bountyPercent ) public onlyOwner() returns(bool) {
		bountyPercent = _bountyPercent;
		return true;
	}
	
	function setPartnerContracts( address _contract ) public onlyOwner() returns(bool) {
		partnerContracts[_contract] = true;
		return true;
	}	
		
	function deposit() public payable { }
		
	function() internal payable {
		ico( msg.sender, msg.value );
	}
	
	function ico( address _to, uint256 _val ) internal returns(bool) {
		require( token != address(0) );
		require( isActive() );
		require( _val >= ( 1 ether / 10 ) );
		require( totalCollected < hardCap );
		
		uint256 tokensAmount = _val.mul( icoPrice ) / 10**10;
		if ( ( icoBonus > 0 ) && ( totalSold.add(tokensAmount) < maxTokensWithBonus ) ) {
			tokensAmount = tokensAmount.add( tokensAmount.mul(icoBonus) / 1000000 );
		} else {
			icoBonus = 0;
		}
		require( totalSold.add(tokensAmount) < token.maxSupply() );
		require( token.issueDuringICO(_to, tokensAmount) );
		
		wingsTokenRewards = wingsTokenRewards.add( tokensAmount.mul( wingsTokenRewardsPercent ) / 1000000 );
		wingsETHRewards = wingsETHRewards.add( _val.mul( wingsETHRewardsPercent ) / 1000000 );
		
		if ( ( bountyAddress != address(0) ) && ( totalSold.add(tokensAmount) < maxTokensWithBonus ) ) {
			require( token.issueDuringICO(bountyAddress, tokensAmount.mul(bountyPercent) / 1000000) );
			tokensAmount = tokensAmount.add( tokensAmount.mul(bountyPercent) / 1000000 );
		}

		totalCollected = totalCollected.add( _val );
		totalSold = totalSold.add( tokensAmount );
		
		return true;
	}
	
	function icoPartner( address _to, uint256 _val ) public returns(bool) {
		require( partnerContracts[msg.sender] );
		require( ico( _to, _val ) );
		return true;
	}
	
	function calculateRewards() public view returns(uint256,uint256) {
		return (wingsETHRewards, wingsTokenRewards);
	}
	
	function releaseTokens() public onlyOwner() hasntStopped() whenCrowdsaleSuccessful() {
		
	}
	
	function withdrawToFounders(uint256 _amount) public whenCrowdsaleSuccessful() onlyOwner() returns(bool) {
		require( address(this).balance.sub( _amount ) >= wingsETHRewards );
        
		uint256 amount_to_withdraw = _amount / foundersAddresses.length;
		uint8 i = 0;
		uint8 errors = 0;        
		for (i = 0; i < foundersAddresses.length; i++) {
			if (!foundersAddresses[i].send(amount_to_withdraw)) {
				errors++;
			}
		}
		
		return true;
	}
}