contract ERC721Receiver {
	  
	  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

	  
	  function onERC721Received(
		address _operator,
		address _from,
		uint256 _tokenId,
		bytes _data
	  )
		public
		returns(bytes4);
	}

	
	library AddressUtils {

	  
	  function isContract(address addr) internal view returns (bool) {
		uint256 size;
		
		
		
		
		
		
		
		assembly { size := extcodesize(addr) }
		return size > 0;
	  }

	}

	
	