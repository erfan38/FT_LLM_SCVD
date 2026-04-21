pragma solidity ^0.4.25;





library SafeMath {

  


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    
    
    
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  


  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); 
    uint256 c = a / b;
    

    return c;
  }

  


  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  


  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  



  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}






contract CryptoxmasEscrow is Pausable, Ownable {
  using SafeMath for uint256;
  
  
  address public givethBridge;
  uint64 public givethReceiverId;

  
  NFT public nft; 
  
  
  uint public EPHEMERAL_ADDRESS_FEE = 0.01 ether;
  uint public MIN_PRICE = 0.05 ether; 
  uint public tokensCounter; 
  
  
  enum Statuses { Empty, Deposited, Claimed, Cancelled }  
  
  struct Gift {
    address sender;
    uint claimEth; 
    uint256 tokenId;
    Statuses status;
    string msgHash; 
  }

  
  mapping (address => Gift) gifts;


  
  enum CategoryId { Common, Special, Rare, Scarce, Limited, Epic, Unique }  
  struct TokenCategory {
    CategoryId categoryId;
    uint minted;  
    uint maxQnty; 
    uint price; 
  }

  
  mapping(string => TokenCategory) tokenCategories;
  
  


  event LogBuy(
	       address indexed transitAddress,
	       address indexed sender,
	       string indexed tokenUri,
	       uint tokenId,
	       uint claimEth,
	       uint nftPrice
	       );

  event LogClaim(
		 address indexed transitAddress,
		 address indexed sender,
		 uint tokenId,
		 address receiver,
		 uint claimEth
		 );  

  event LogCancel(
		  address indexed transitAddress,
		  address indexed sender,
		  uint tokenId
		  );

  event LogAddTokenCategory(
			    string tokenUri,
			    CategoryId categoryId,
			    uint maxQnty,
			    uint price
		  );
  

  









  constructor(address _givethBridge,
	      uint64 _givethReceiverId,
	      string _name,
	      string _symbol) public {
    
    givethBridge = _givethBridge;
    givethReceiverId = _givethReceiverId;
    
    
    nft = new NFT(_name, _symbol);
  }

   


  
  




  
  function getTokenCategory(string _tokenUri) public view returns (CategoryId categoryId,
								  uint minted,
								  uint maxQnty,
								  uint price) { 
    TokenCategory memory category = tokenCategories[_tokenUri];    
    return (category.categoryId,
	    category.minted,
	    category.maxQnty,
	    category.price);
  }

  







    
  function addTokenCategory(string _tokenUri, CategoryId _categoryId, uint _maxQnty, uint _price)
    public onlyOwner returns (bool success) {

    
    require(_price >= MIN_PRICE);
	    
    
    require(tokenCategories[_tokenUri].price == 0);
    
    tokenCategories[_tokenUri] = TokenCategory(_categoryId,
					       0, 
					       _maxQnty,
					       _price);

    emit LogAddTokenCategory(_tokenUri, _categoryId, _maxQnty, _price);
    return true;
  }

  






      
  function canBuyGift(string _tokenUri, address _transitAddress, uint _value) public view whenNotPaused returns (bool) {
    
    require(gifts[_transitAddress].status == Statuses.Empty);

    
    TokenCategory memory category = tokenCategories[_tokenUri];
    require(_value >= category.price);

    
    require(category.minted < category.maxQnty);
    
    return true;
  }

  












    
  function buyGift(string _tokenUri, address _transitAddress, string _msgHash)
          payable public whenNotPaused returns (bool) {
    
    require(canBuyGift(_tokenUri, _transitAddress, msg.value));

    
    uint tokenPrice = tokenCategories[_tokenUri].price;

    
    uint claimEth = msg.value.sub(tokenPrice);

    
    uint tokenId = tokensCounter.add(1);
    nft.mintWithTokenURI(tokenId, _tokenUri);

    
    tokenCategories[_tokenUri].minted = tokenCategories[_tokenUri].minted.add(1);
    tokensCounter = tokensCounter.add(1);
    
    
    gifts[_transitAddress] = Gift(
				  msg.sender,
				  claimEth,
				  tokenId,
				  Statuses.Deposited,
				  _msgHash
				  );


    
    _transitAddress.transfer(EPHEMERAL_ADDRESS_FEE);

    
    uint donation = tokenPrice.sub(EPHEMERAL_ADDRESS_FEE);
    if (donation > 0) {
      bool donationSuccess = _makeDonation(msg.sender, donation);

      
      require(donationSuccess == true);
    }
    
    
    emit LogBuy(
		_transitAddress,
		msg.sender,
		_tokenUri,
		tokenId,
		claimEth,
		tokenPrice);
    return true;
  }

  






    
  function _makeDonation(address _giver, uint _value) internal returns (bool success) {
    bytes memory _data = abi.encodePacked(0x1870c10f, 
					   bytes32(_giver),
					   bytes32(givethReceiverId),
					   bytes32(0),
					   bytes32(0));
    
    success = givethBridge.call.value(_value)(_data);
    return success;
  }

  




    
  function getGift(address _transitAddress) public view returns (
	     uint256 tokenId,
	     string tokenUri,								 
	     address sender,  
	     uint claimEth,   
	     uint nftPrice,   
	     Statuses status, 
	     string msgHash   
    ) {
    Gift memory gift = gifts[_transitAddress];
    tokenUri =  nft.tokenURI(gift.tokenId);
    TokenCategory memory category = tokenCategories[tokenUri];    
    return (
	    gift.tokenId,
	    tokenUri,
	    gift.sender,
	    gift.claimEth,
	    category.price,	    
	    gift.status,
	    gift.msgHash
	    );
  }
  
  






  function cancelGift(address _transitAddress) public returns (bool success) {
    Gift storage gift = gifts[_transitAddress];

    
    require(gift.status == Statuses.Deposited);
    
    
    require(msg.sender == gift.sender);
    
    
    gift.status = Statuses.Cancelled;

    
    if (gift.claimEth > 0) {
      gift.sender.transfer(gift.claimEth);
    }

    
    nft.transferFrom(address(this), msg.sender, gift.tokenId);

    
    emit LogCancel(_transitAddress, msg.sender, gift.tokenId);

    return true;
  }

  
  






  function claimGift(address _receiver) public whenNotPaused returns (bool success) {
    
    address _transitAddress = msg.sender;
    
    Gift storage gift = gifts[_transitAddress];

    
    require(gift.status == Statuses.Deposited);

    
    gift.status = Statuses.Claimed;
    
    
    nft.transferFrom(address(this), _receiver, gift.tokenId);
    
    
    if (gift.claimEth > 0) {
      _receiver.transfer(gift.claimEth);
    }

    
    emit LogClaim(_transitAddress, gift.sender, gift.tokenId, _receiver, gift.claimEth);
    
    return true;
  }

  
  function() public payable {
    revert();
  }
}