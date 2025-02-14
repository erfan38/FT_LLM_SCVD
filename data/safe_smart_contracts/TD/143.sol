contract Whitelistable is WhitelistableI, Ownable {
    using ECRecovery for bytes32;

    address public whitelistAdmin;

     
    mapping(bytes32 => bool) public invalidHash;

    event AdminUpdated(address indexed newAdmin);

    modifier validAdmin(address _admin) {
        require(_admin != 0);
        _;
    }

    modifier onlyAdmin {
        require(msg.sender == whitelistAdmin);
        _;
    }

    modifier isWhitelisted(bytes32 _hash, bytes _sig) {
        require(checkWhitelisted(_hash, _sig));
        _;
    }

     
     
    constructor(address _admin) public validAdmin(_admin) {
        whitelistAdmin = _admin;        
    }

     
     
     
    function changeAdmin(address _admin)
        external
        onlyOwner
        validAdmin(_admin)
    {
        emit AdminUpdated(_admin);
        whitelistAdmin = _admin;
    }

     
     
    function invalidateHash(bytes32 _hash) external onlyAdmin {
        invalidHash[_hash] = true;
    }

    function invalidateHashes(bytes32[] _hashes) external onlyAdmin {
        for (uint i = 0; i < _hashes.length; i++) {
            invalidHash[_hashes[i]] = true;
        }
    }

     
     
     
     
    function checkWhitelisted(
        bytes32 _rawHash,
        bytes _sig
    )
        public
        view
        returns(bool)
    {
        bytes32 hash = _rawHash.toEthSignedMessageHash();
        return !invalidHash[_rawHash] && whitelistAdmin == hash.recover(_sig);
    }
}

 

interface EthPriceFeedI {
    function getUnit() external view returns(string);
    function getRate() external view returns(uint256);
    function getLastTimeUpdated() external view returns(uint256); 
}

 

interface SaleI {
    function setup() external;  
    function changeEthPriceFeed(EthPriceFeedI newPriceFeed) external;
    function contribute(address _contributor, uint256 _limit, uint256 _expiration, bytes _sig) external payable; 
    function allocateExtraTokens(address _contributor) external;
    function setEndTime(uint256 _endTime) external;
    function endSale() external;
}

 

