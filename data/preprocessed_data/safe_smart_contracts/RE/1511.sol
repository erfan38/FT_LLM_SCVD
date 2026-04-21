contract Campaign {

    uint public startFundingTime;       // In UNIX Time Format
    uint public endFundingTime;         // In UNIX Time Format
    uint public maximumFunding;         // In wei
    uint public totalCollected;         // In wei
    CampaignToken public tokenContract;  // The new token for this Campaign
    address public vaultContract;       // The address to hold the funds donated

/// @notice 'Campaign()' initiates the Campaign by setting its funding
/// parameters and creating the deploying the token contract
/// @dev There are several checks to make sure the parameters are acceptable
/// @param _startFundingTime The UNIX time that the Campaign will be able to
/// start receiving funds
/// @param _endFundingTime The UNIX time that the Campaign will stop being able
/// to receive funds
/// @param _maximumFunding In wei, the Maximum amount that the Campaign can
/// receive (currently the max is set at 10,000 ETH for the beta)
/// @param _vaultContract The address that will store the donated funds

    function Campaign(
        uint _startFundingTime,
        uint _endFundingTime,
        uint _maximumFunding,
        address _vaultContract
    ) {
        if ((_endFundingTime < now) ||                // Cannot start in the past
            (_endFundingTime <= _startFundingTime) ||
            (_maximumFunding > 10000 ether) ||        // The Beta is limited
            (_vaultContract == 0))                    // To prevent burning ETH
            {
            throw;
            }
        startFundingTime = _startFundingTime;
        endFundingTime = _endFundingTime;
        maximumFunding = _maximumFunding;
        tokenContract = new CampaignToken (); // Deploys the Token Contract
        vaultContract = _vaultContract;
    }

/// @dev The fallback function is called when ether is sent to the contract, it
/// simply calls `doPayment()` with the address that sent the ether as the
/// `_owner`. Payable is a required solidity modifier for functions to receive
/// ether, without this modifier they will throw

    function ()  payable {
        doPayment(msg.sender);
    }

/// @notice `proxyPayment()` allows the caller to send ether to the Campaign and
/// have the CampaignTokens created in an address of their choosing
/// @param _owner The address that will hold the newly created CampaignTokens

    function proxyPayment(address _owner) payable {
        doPayment(_owner);
    }

/// @dev `doPayment()` is an internal function that sends the ether that this
/// 