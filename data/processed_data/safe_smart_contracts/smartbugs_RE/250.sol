contract AbstractDaoChallenge {
	function isMember (DaoAccount account, address allegedOwnerAddress) returns (bool);
}

contract DaoAccount
{
	



	



	

	




	



	uint256 tokenBalance; 
  address owner;        
	address daoChallenge; 
	uint256 tokenPrice;

  
  
  address challengeOwner;

	



	modifier noEther() {if (msg.value > 0) throw; _}

	modifier onlyOwner() {if (owner != msg.sender) throw; _}

	modifier onlyDaoChallenge() {if (daoChallenge != msg.sender) throw; _}

	modifier onlyChallengeOwner() {if (challengeOwner != msg.sender) throw; _}

	



  function DaoAccount (address _owner, uint256 _tokenPrice, address _challengeOwner) noEther {
    owner = _owner;
		tokenPrice = _tokenPrice;
    daoChallenge = msg.sender;
		tokenBalance = 0;

    
    challengeOwner = _challengeOwner;
	}

	function () {
		throw;
	}

	



	



	function getOwnerAddress() constant returns (address ownerAddress) {
		return owner;
	}

	function getTokenBalance() constant returns (uint256 tokens) {
		return tokenBalance;
	}

	function buyTokens() onlyDaoChallenge returns (uint256 tokens) {
		uint256 amount = msg.value;

		
		if (amount == 0) throw;

		
		if (amount % tokenPrice != 0) throw;

		tokens = amount / tokenPrice;

		tokenBalance += tokens;

		return tokens;
	}

	function withdraw(uint256 tokens) noEther onlyDaoChallenge {
		if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
		tokenBalance -= tokens;
		if(!owner.call.value(tokens * tokenPrice)()) throw;
	}

	function transfer(uint256 tokens, DaoAccount recipient) noEther onlyDaoChallenge {
		if (tokens == 0 || tokenBalance == 0 || tokenBalance < tokens) throw;
		tokenBalance -= tokens;
		recipient.receiveTokens.value(tokens * tokenPrice)(tokens);
	}

	function receiveTokens(uint256 tokens) {
		
		DaoAccount sender = DaoAccount(msg.sender);
		if (!AbstractDaoChallenge(daoChallenge).isMember(sender, sender.getOwnerAddress())) throw;

		uint256 amount = msg.value;

		
		if (amount == 0) throw;

		if (amount / tokenPrice != tokens) throw;

		tokenBalance += tokens;
	}

	
	function terminate() noEther onlyChallengeOwner {
		suicide(challengeOwner);
	}
}