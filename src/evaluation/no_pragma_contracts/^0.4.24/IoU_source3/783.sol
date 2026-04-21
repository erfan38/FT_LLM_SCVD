contract CryptoCaps is ERC721Token, Ownable {

	  
	  
	  event BoughtToken(address indexed buyer, uint256 tokenId);

	  
	  uint8 constant TITLE_MIN_LENGTH = 1;
	  uint8 constant TITLE_MAX_LENGTH = 64;
	  uint256 constant DESCRIPTION_MIN_LENGTH = 1;
	  uint256 constant DESCRIPTION_MAX_LENGTH = 10000;

	  

	  
	  
	  
	  uint256 currentPrice = 0;

	  
	  mapping(uint256 => uint256) tokenTypes;

	  
	  mapping(uint256 => string) tokenTitles;
	  
	  
	  mapping(uint256 => string) tokenDescription;

	  constructor() ERC721Token("CryptoCaps", "QCC") public {
		
	  }

	  
	  
	  
	  
	  
	  function buyToken (
		uint256 _type,
		string _title,
		string _description
	  ) external payable {
		bytes memory _titleBytes = bytes(_title);
		require(_titleBytes.length >= TITLE_MIN_LENGTH, "Title is too short");
		require(_titleBytes.length <= TITLE_MAX_LENGTH, "Title is too long");
		
		bytes memory _descriptionBytes = bytes(_description);
		require(_descriptionBytes.length >= DESCRIPTION_MIN_LENGTH, "Description is too short");
		require(_descriptionBytes.length <= DESCRIPTION_MAX_LENGTH, "Description is too long");
		require(msg.value >= currentPrice, "Amount of Ether sent too small");

		uint256 index = allTokens.length + 1;

		_mint(msg.sender, index);

		tokenTypes[index] = _type;
		tokenTitles[index] = _title;
		tokenDescription[index] = _description;

		emit BoughtToken(msg.sender, index);
	  }

	  
	  function myTokens()
		external
		view
		returns (
		  uint256[]
		)
	  {
		return ownedTokens[msg.sender];
	  }

	  
	  
	  function viewToken(uint256 _tokenId)
		external
		view
		returns (
		  uint256 tokenType_,
		  string tokenTitle_,
		  string tokenDescription_
	  ) {
		  tokenType_ = tokenTypes[_tokenId];
		  tokenTitle_ = tokenTitles[_tokenId];
		  tokenDescription_ = tokenDescription[_tokenId];
	  }

	  
	  function setCurrentPrice(uint256 newPrice)
		public
		onlyOwner
	  {
		  currentPrice = newPrice;
	  }

	  
	  function getCurrentPrice()
		external
		view
		returns (
		uint256 price
	  ) {
		  price = currentPrice;
	  }
	  
	   function kill() public {
		  if(msg.sender == owner) selfdestruct(owner);
	   }  
	}