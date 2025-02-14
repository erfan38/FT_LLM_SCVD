contract DivisibleForeverRose is ERC721 {
  
    //This contract's owner
    address private contractOwner;

    
    //Gift token storage.
    mapping(uint => GiftToken) giftStorage;

    // Total supply of this token. 
	uint public totalSupply = 10; 

    bool public tradable = false;

    uint foreverRoseId = 1;

    // Divisibility of ownership over a token  
	mapping(address => mapping(uint => uint)) ownerToTokenShare;

	// How much owners have of a token
	mapping(uint => mapping(address => uint)) tokenToOwnersHoldings;

    // If Forever Rose has been created
	mapping(uint => bool) foreverRoseCreated;

    string public name;  
    string public symbol;           
    uint8 public decimals = 1;                                 
    string public version = "1.0";    

    //Special gift token
    struct GiftToken {
        uint256 giftId;
    } 

    //@dev Constructor 
    function DivisibleForeverRose() public {
        contractOwner = msg.sender;
        name = "ForeverRose";
        symbol = "ROSE";  

        // Create Forever rose
        GiftToken memory newGift = GiftToken({
            giftId: foreverRoseId
        });
        giftStorage[foreverRoseId] = newGift;

        
        foreverRoseCreated[foreverRoseId] = true;
        _addNewOwnerHoldingsToToken(contractOwner, foreverRoseId, totalSupply);
        _addShareToNewOwner(contractOwner, foreverRoseId, totalSupply);

    }
    
    // Fallback funciton
    function() public {
        revert();
    }

    function totalSupply() public view returns (uint256 total) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerToTokenShare[_owner][foreverRoseId];
    }

    // We use parameter '_tokenId' as the divisibility
    function transfer(address _to, uint256 _tokenId) external {

        // Requiring this 