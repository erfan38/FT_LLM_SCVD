contract HeartBoutPreICO is CappedCrowdsale, Ownable {
    using SafeMath for uint256;
    
    // The token address
    address public token;
    uint256 public minCount;
    // Bind User Account and Address Wallet
    mapping(string => address) bindAccountsAddress;
    mapping(address => string) bindAddressAccounts;
    string[] accounts;
    event GetBindTokensAccountEvent(address _address, string _account);
    function HeartBoutPreICO(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _cap, uint256 _minCount) public
    CappedCrowdsale(_startTime, _endTime, _rate, _wallet, _cap)
    {
        token = 0x00305cB299cc82a8A74f8da00AFA6453741d9a15Ed;
        minCount = _minCount;
    }
    // fallback function can be used to buy tokens
    function () payable public {
    }
    // low level token purchase function
    function buyTokens(string _account) public payable {
        require(!stringEqual(_account, ""));
        require(validPurchase());
        require(msg.value >= minCount);
        // throw if address was bind with another account
        if(!stringEqual(bindAddressAccounts[msg.sender], "")) {
            require(stringEqual(bindAddressAccounts[msg.sender], _account));
        }
        uint256 weiAmount = msg.value;
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);
        // Mint only message sender address
        require(token.call(bytes4(keccak256("mint(address,uint256)")), msg.sender, tokens));
        bindAccountsAddress[_account] = msg.sender;
        bindAddressAccounts[msg.sender] = _account;
        accounts.push(_account);
        // update state
        weiRaised = weiRaised.add(weiAmount);
        forwardFunds();
    }
    function getEachBindAddressAccount() onlyOwner public {
        // get transfered account and addresses
        for (uint i = 0; i < accounts.length; i++) {
            GetBindTokensAccountEvent(bindAccountsAddress[accounts[i]], accounts[i]);
        }
    }
    function getBindAccountAddress(string _account) public constant returns (address) {
        return bindAccountsAddress[_account];
    }
    function getBindAddressAccount(address _accountAddress) public constant returns (string) {
        return bindAddressAccounts[_accountAddress];
    }
    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }
    function stringEqual(string _a, string _b) internal pure returns (bool) {
        return keccak256(_a) == keccak256(_b);
    }
    // change wallet
    function changeWallet(address _wallet) onlyOwner public {
        wallet = _wallet;
    }
    // Remove 