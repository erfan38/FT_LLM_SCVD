pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;
pragma experimental "v0.5.0";






library SafeMath {
	int256 constant private INT256_MIN = -2**255;

	


	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		
		
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	


	function mul(int256 a, int256 b) internal pure returns (int256) {
		
		
		if (a == 0) {
			return 0;
		}

		require(!(a == -1 && b == INT256_MIN)); 

		int256 c = a * b;
		require(c / a == b);

		return c;
	}

	


	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		
		require(b > 0);
		uint256 c = a / b;
		

		return c;
	}

	


	function div(int256 a, int256 b) internal pure returns (int256) {
		require(b != 0); 
		require(!(b == -1 && a == INT256_MIN)); 

		int256 c = a / b;

		return c;
	}

	


	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	


	function sub(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a - b;
		require((b >= 0 && c <= a) || (b < 0 && c > a));

		return c;
	}

	


	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	


	function add(int256 a, int256 b) internal pure returns (int256) {
		int256 c = a + b;
		require((b >= 0 && c >= a) || (b < 0 && c < a));

		return c;
	}

	


	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}






library SafeMathFixedPoint {
	using SafeMath for uint256;

	function mul27(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(y).add(5 * 10**26).div(10**27);
	}
	function mul18(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(y).add(5 * 10**17).div(10**18);
	}

	function div18(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(10**18).add(y.div(2)).div(y);
	}
	function div27(uint256 x, uint256 y) internal pure returns (uint256 z) {
		z = x.mul(10**27).add(y.div(2)).div(y);
	}
}







contract LiquidLong is Ownable, Claimable, Pausable {
	using SafeMath for uint256;
	using SafeMathFixedPoint for uint256;

	uint256 public providerFeePerEth;

	Oasis public oasis;
	Maker public maker;
	Dai public dai;
	Weth public weth;
	Peth public peth;
	Mkr public mkr;

	ProxyRegistry public proxyRegistry;

	event NewCup(address user, bytes32 cup);

	constructor(Oasis _oasis, Maker _maker, ProxyRegistry _proxyRegistry) public payable {
		providerFeePerEth = 0.01 ether;

		oasis = _oasis;
		maker = _maker;
		dai = maker.sai();
		weth = maker.gem();
		peth = maker.skr();
		mkr = maker.gov();

		
		dai.approve(address(_oasis), uint256(-1));
		
		dai.approve(address(_maker), uint256(-1));
		mkr.approve(address(_maker), uint256(-1));
		
		weth.approve(address(_maker), uint256(-1));
		
		peth.approve(address(_maker), uint256(-1));

		proxyRegistry = _proxyRegistry;

		if (msg.value > 0) {
			weth.deposit.value(msg.value)();
		}
	}

	
	function () external payable {
	}

	function wethDeposit() public payable {
		weth.deposit.value(msg.value)();
	}

	function wethWithdraw(uint256 _amount) public onlyOwner {
		weth.withdraw(_amount);
		owner.transfer(_amount);
	}

	function attowethBalance() public view returns (uint256 _attoweth) {
		return weth.balanceOf(address(this));
	}

	function ethWithdraw() public onlyOwner {
		uint256 _amount = address(this).balance;
		owner.transfer(_amount);
	}

	function transferTokens(ERC20 _token) public onlyOwner {
		_token.transfer(owner, _token.balanceOf(this));
	}

	function ethPriceInUsd() public view returns (uint256 _attousd) {
		return uint256(maker.pip().read());
	}

	function estimateDaiSaleProceeds(uint256 _attodaiToSell) public view returns (uint256 _daiPaid, uint256 _wethBought) {
		return getPayPriceAndAmount(dai, weth, _attodaiToSell);
	}

	
	function getPayPriceAndAmount(ERC20 _payGem, ERC20 _buyGem, uint256 _payDesiredAmount) public view returns (uint256 _paidAmount, uint256 _boughtAmount) {
		uint256 _offerId = oasis.getBestOffer(_buyGem, _payGem);
		while (_offerId != 0) {
			uint256 _payRemaining = _payDesiredAmount.sub(_paidAmount);
			(uint256 _buyAvailableInOffer,  , uint256 _payAvailableInOffer,) = oasis.getOffer(_offerId);
			if (_payRemaining <= _payAvailableInOffer) {
				uint256 _buyRemaining = _payRemaining.mul(_buyAvailableInOffer).div(_payAvailableInOffer);
				_paidAmount = _paidAmount.add(_payRemaining);
				_boughtAmount = _boughtAmount.add(_buyRemaining);
				break;
			}
			_paidAmount = _paidAmount.add(_payAvailableInOffer);
			_boughtAmount = _boughtAmount.add(_buyAvailableInOffer);
			_offerId = oasis.getWorseOffer(_offerId);
		}
		return (_paidAmount, _boughtAmount);
	}

	modifier wethBalanceIncreased() {
		uint256 _startingAttowethBalance = weth.balanceOf(this);
		_;
		require(weth.balanceOf(this) > _startingAttowethBalance);
	}

	
	function openCdp(uint256 _leverage, uint256 _leverageSizeInAttoeth, uint256 _allowedFeeInAttoeth, address _affiliateAddress) public payable wethBalanceIncreased returns (bytes32 _cdpId) {
		require(_leverage >= 100 && _leverage <= 300);
		uint256 _lockedInCdpInAttoeth = _leverageSizeInAttoeth.mul(_leverage).div(100);
		uint256 _loanInAttoeth = _lockedInCdpInAttoeth.sub(_leverageSizeInAttoeth);
		uint256 _feeInAttoeth = _loanInAttoeth.mul18(providerFeePerEth);
		require(_feeInAttoeth <= _allowedFeeInAttoeth);
		uint256 _drawInAttodai = _loanInAttoeth.mul18(uint256(maker.pip().read()));
		uint256 _attopethLockedInCdp = _lockedInCdpInAttoeth.div27(maker.per());

		
		weth.deposit.value(msg.value)();
		
		_cdpId = maker.open();
		
		maker.join(_attopethLockedInCdp);
		
		maker.lock(_cdpId, _attopethLockedInCdp);
		
		maker.draw(_cdpId, _drawInAttodai);
		
		sellDai(_drawInAttodai, _lockedInCdpInAttoeth, _feeInAttoeth);
		
		if (_affiliateAddress != address(0)) {
			
			
			weth.transfer(_affiliateAddress, _feeInAttoeth.div(2));
		}

		emit NewCup(msg.sender, _cdpId);

		giveCdpToProxy(msg.sender, _cdpId);
	}

	function giveCdpToProxy(address _ownerOfProxy, bytes32 _cdpId) private {
		DSProxy _proxy = proxyRegistry.proxies(_ownerOfProxy);
		if (_proxy == DSProxy(0) || _proxy.owner() != _ownerOfProxy) {
			_proxy = proxyRegistry.build(_ownerOfProxy);
		}
		
		maker.give(_cdpId, _proxy);
	}

	
	function sellDai(uint256 _drawInAttodai, uint256 _lockedInCdpInAttoeth, uint256 _feeInAttoeth) private {
		uint256 _wethBoughtInAttoweth = oasis.sellAllAmount(dai, _drawInAttodai, weth, 0);
		
		uint256 _refundDue = msg.value.add(_wethBoughtInAttoweth).sub(_lockedInCdpInAttoeth).sub(_feeInAttoeth);
		if (_refundDue > 0) {
			weth.withdraw(_refundDue);
			require(msg.sender.call.value(_refundDue)());
		}
	}
}