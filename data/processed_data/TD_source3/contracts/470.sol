contract Whitelisted is Ownable {

     
    bool public whitelistEnabled = true;

     
    mapping(address => bool) public whitelist;

    event ICOWhitelisted(address indexed addr);
    event ICOBlacklisted(address indexed addr);

    modifier onlyWhitelisted {
        require(!whitelistEnabled || whitelist[msg.sender]);
        _;
    }

     
    function whitelist(address address_) external onlyOwner {
        whitelist[address_] = true;
        emit ICOWhitelisted(address_);
    }

     
    function blacklist(address address_) external onlyOwner {
        delete whitelist[address_];
        emit ICOBlacklisted(address_);
    }

     
    function whitelisted(address address_) public view returns (bool) {
        if (whitelistEnabled) {
            return whitelist[address_];
        } else {
            return true;
        }
    }

     
    function enableWhitelist() public onlyOwner {
        whitelistEnabled = true;
    }

     
    function disableWhitelist() public onlyOwner {
        whitelistEnabled = false;
    }
}

 

interface ERC20Token {
    function balanceOf(address owner_) external returns (uint);
    function allowance(address owner_, address spender_) external returns (uint);
    function transferFrom(address from_, address to_, uint value_) external returns (bool);
}

 

 
