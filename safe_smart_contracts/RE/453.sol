contract Presale is Ownable {
    using SafeMath for uint256;
    Token public tokenContract;
    
	uint8 public decimals;
    uint256 public tokenValue;  // 1 Token in wei
    uint256 public centToken; // euro cents value of 1 token 

    uint256 public endTime;  // seconds from 1970-01-01T00:00:00Z
    uint256 public startTime;  // seconds from 1970-01-01T00:00:00Z

    function Presale() public {
        //Configuration
        centToken = 25; // Euro cents value of 1 token 
        
        tokenValue = 402693728269933; // centToken in wei of ether 04/12/2017
        startTime = 1513625400; // 18/12/2017 20:30 UTC+1
        endTime = 1516476600; // 20/01/2018 20:30 UTC+1
		
		uint256 totalSupply = 12000000; // 12.000.000 * 0.25€ = 3.000.000€ CAPPED
		decimals = 18;
		string memory name = "MethaVoucher";
		string memory symbol = "MTV";
		
		//End Configuration
		
        tokenContract = new Token(totalSupply, decimals, name, symbol);
		//tokenContract.setAuthorized(this, true); // Authorizable constructor set msg.sender to true
		tokenContract.transferOwnership(msg.sender);
    }

    address public updater;  // account in charge of updating the token value
    event UpdateValue(uint256 newValue);

    function updateValue(uint256 newValue) public {
        require(msg.sender == updater || msg.sender == owner);
        tokenValue = newValue;
        UpdateValue(newValue);
    }

    function updateUpdater(address newUpdater) public onlyOwner {
        updater = newUpdater;
    }

    function updateTime(uint256 _newStart, uint256 _newEnd) public onlyOwner {
        if ( _newStart != 0 ) startTime = _newStart;
        if ( _newEnd != 0 ) endTime = _newEnd;
    }
    
    event Buy(address buyer, uint256 value);

    function buy(address _buyer) public payable returns(uint256) {
        require(now > startTime); // check if started
        require(now < endTime); // check if ended
        require(msg.value > 0);
		
		uint256 remainingTokens = tokenContract.balanceOf(this);
        require( remainingTokens > 0 ); // Check if there are any remaining tokens 
        
        uint256 oneToken = 10 ** uint256(decimals);
        uint256 tokenAmount = msg.value.mul(oneToken).div(tokenValue);
        
        if ( remainingTokens < tokenAmount ) {
            uint256 refund = (tokenAmount - remainingTokens).mul(tokenValue).div(oneToken);
            tokenAmount = remainingTokens;
            owner.transfer(msg.value-refund);
			remainingTokens = 0; // set remaining token to 0
             _buyer.transfer(refund);
        } else {
			remainingTokens = remainingTokens.sub(tokenAmount); // update remaining token without bonus
            owner.transfer(msg.value);
        }
        
        tokenContract.transfer(_buyer, tokenAmount);
        Buy(_buyer, tokenAmount);
		
        return tokenAmount; 
    }

    function withdraw(address to, uint256 value) public onlyOwner {
        to.transfer(value);
    }
    
    function updateTokenContract(address _tokenContract) public onlyOwner {
        tokenContract = Token(_tokenContract);
    }

    function withdrawTokens(address to, uint256 value) public onlyOwner returns (bool) {
        return tokenContract.transfer(to, value);
    }

    function () public payable {
        buy(msg.sender);
    }
}