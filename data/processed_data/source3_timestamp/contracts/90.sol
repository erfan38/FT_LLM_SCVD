contract TwoYearDreamTokensVesting {

    using SafeMath for uint256;

     
    ERC20TokenInterface public dreamToken;

     
    address public withdrawalAddress = 0x0;

     
    struct VestingStage {
        uint256 date;
        uint256 tokensUnlockedPercentage;
    }

     
    VestingStage[4] public stages;

     
    uint256 public initialTokensBalance;

     
    uint256 public tokensSent;

     
    uint256 public vestingStartUnixTimestamp;

     
    address public deployer;

    modifier deployerOnly { require(msg.sender == deployer); _; }
    modifier whenInitialized { require(withdrawalAddress != 0x0); _; }
    modifier whenNotInitialized { require(withdrawalAddress == 0x0); _; }

     
    event Withdraw(uint256 amount, uint256 timestamp);

     
    constructor (ERC20TokenInterface token) public {
        dreamToken = token;
        deployer = msg.sender;
    }

     
    function () external {
        withdrawTokens();
    }

     
    function initializeVestingFor (address account) external deployerOnly whenNotInitialized {
        initialTokensBalance = dreamToken.balanceOf(this);
        require(initialTokensBalance != 0);
        withdrawalAddress = account;
        vestingStartUnixTimestamp = block.timestamp;
        vestingRules();
    }

     
    function getAvailableTokensToWithdraw () public view returns (uint256) {
        uint256 tokensUnlockedPercentage = getTokensUnlockedPercentage();
         
         
        if (tokensUnlockedPercentage >= 100) {
            return dreamToken.balanceOf(this);
        } else {
            return getTokensAmountAllowedToWithdraw(tokensUnlockedPercentage);
        }
    }

     
    function vestingRules () internal {

        uint256 halfOfYear = 183 days;
        uint256 year = halfOfYear * 2;

        stages[0].date = vestingStartUnixTimestamp + halfOfYear;
        stages[1].date = vestingStartUnixTimestamp + year;
        stages[2].date = vestingStartUnixTimestamp + year + halfOfYear;
        stages[3].date = vestingStartUnixTimestamp + (year * 2);

        stages[0].tokensUnlockedPercentage = 25;
        stages[1].tokensUnlockedPercentage = 50;
        stages[2].tokensUnlockedPercentage = 75;
        stages[3].tokensUnlockedPercentage = 100;

    }

     
    function withdrawTokens () private whenInitialized {
        uint256 tokensToSend = getAvailableTokensToWithdraw();
        sendTokens(tokensToSend);
        if (dreamToken.balanceOf(this) == 0) {  
            selfdestruct(withdrawalAddress);
        }
    }

     
    function sendTokens (uint256 tokensToSend) private {
        if (tokensToSend == 0) {
            return;
        }
        tokensSent = tokensSent.add(tokensToSend);  
        dreamToken.transfer(withdrawalAddress, tokensToSend);  
        emit Withdraw(tokensToSend, now);  
    }

     
    function getTokensAmountAllowedToWithdraw (uint256 tokensUnlockedPercentage) private view returns (uint256) {
        uint256 totalTokensAllowedToWithdraw = initialTokensBalance.mul(tokensUnlockedPercentage).div(100);
        uint256 unsentTokensAmount = totalTokensAllowedToWithdraw.sub(tokensSent);
        return unsentTokensAmount;
    }

     
    function getTokensUnlockedPercentage () private view returns (uint256) {

        uint256 allowedPercent;

        for (uint8 i = 0; i < stages.length; i++) {
            if (now >= stages[i].date) {
                allowedPercent = stages[i].tokensUnlockedPercentage;
            }
        }

        return allowedPercent;

    }

}