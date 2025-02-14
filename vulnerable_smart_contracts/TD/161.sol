contract ICO is HardcodedWallets, Haltable {
	 

	 
	Tokens public SCTokens;	 
	RefundVault public SCRefundVault;	 
	Whitelist public SCWhitelist;	 
	Escrow public SCEscrow;  

	 
	uint256 public startTime;
	uint256 public endTime;
	bool public isFinalized = false;

	uint256 public weisPerBigToken;  
	uint256 public weisPerEther;
	uint256 public tokensPerEther;  
	uint256 public bigTokensPerEther;  

	uint256 public weisRaised;  
	uint256 public etherHardCap;  
	uint256 public tokensHardCap;  
	uint256 public weisHardCap;  
	uint256 public weisMinInvestment;  
	uint256 public etherSoftCap;  
	uint256 public tokensSoftCap;  
	uint256 public weisSoftCap;  

	uint256 public discount;  
	uint256 discountedPricePercentage;
	uint8 ICOStage;



	 

	
	 

	 
	function () payable public {
		buyTokens();
	}
	

	 
	function buyTokens() public stopInEmergency payable returns (bool) {
		if (msg.value == 0) {
			error('buyTokens: ZeroPurchase');
			return false;
		}

		uint256 tokenAmount = buyTokensLowLevel(msg.sender, msg.value);

		 
		if (!SCRefundVault.deposit.value(msg.value)(msg.sender, tokenAmount)) {
			revert('buyTokens: unable to transfer collected funds from ICO 